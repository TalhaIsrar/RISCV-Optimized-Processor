module div_controller #(
    parameter COUNT = 6'd31
)(
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic [31:0] dividend,
    input  logic [31:0] divisor,
    input  logic        is_signed, 

    output logic load,
    output logic iterate,
    output logic finish,
    output logic done,
    output logic busy,

    output logic        special_case,
    output logic [31:0] special_q,
    output logic [31:0] special_r
);

    logic div_by_zero;
    logic overflow;

    // Registers
    logic [31:0] count;

    // Detect special cases
    assign div_by_zero = (divisor == 0);
    assign overflow   = is_signed && (dividend == 32'h80000000 && divisor == 32'hFFFFFFFF);

    // FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            busy            <= 0;
            count           <= 0;
            done            <= 0;
            special_case    <= 0;
            special_q       <= 0;
            special_r       <= 0;
        end
        else begin
            done <= 0;  // default

            // Start condition
            if (start && !busy && !special_case) begin
                if (div_by_zero || overflow) begin
                    special_case <= 1;
                    special_q    <= div_by_zero ? 32'hFFFFFFFF : 32'h80000000;
                    special_r    <= div_by_zero ? dividend : 32'd0;
                end
                else begin
                    busy  <= 1;
                    count <= 0;
                end
            end

            // Special case completes in 1 cycle
            else if (special_case) begin
                done           <= 1;
                special_case   <= 0;
            end

            // Normal running
            else if (busy) begin
                count <= count + 1;
                if (count == COUNT) begin
                    busy <= 0;
                    done <= 1;
                end
            end
        end
    end

    // Outputs
    assign load = (start && !busy && !special_case && !(div_by_zero || overflow));
    assign iterate = busy;
    assign finish = (busy && count == COUNT) || special_case;

endmodule
