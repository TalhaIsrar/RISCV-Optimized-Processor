module bimodal_base #(
    parameter IDXW = 10   // 1024 entries default
)(
    input  logic                clk,
    input  logic                rst,

    // ===== Prediction (IF stage) =====
    input  logic [IDXW-1:0]     index_i,
    output logic                pred_o,

    // ===== Update (EX stage) =====
    input  logic                update_i,
    input  logic [IDXW-1:0]     update_index_i,
    input  logic                taken_i
);

    localparam ENTRIES = (1 << IDXW);

    // 2-bit counters
    logic [1:0] bimodel_table [ENTRIES-1:0];

    integer i;

    // ----------------------------
    // Reset
    // ----------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < ENTRIES; i++) begin
                bimodel_table[i] <= 2'b01;  // weak NOT TAKEN
            end
        end
    end

    // ----------------------------
    // Prediction (combinational read)
    // ----------------------------
    assign pred_o = bimodel_table[index_i][1];

    // ----------------------------
    // Update (sequential)
    // ----------------------------
    always_ff @(posedge clk) begin
        if (!rst && update_i) begin
            case (bimodel_table[update_index_i])
                2'b00: bimodel_table[update_index_i] <= taken_i ? 2'b01 : 2'b00;
                2'b01: bimodel_table[update_index_i] <= taken_i ? 2'b10 : 2'b00;
                2'b10: bimodel_table[update_index_i] <= taken_i ? 2'b11 : 2'b01;
                2'b11: bimodel_table[update_index_i] <= taken_i ? 2'b11 : 2'b10;
            endcase
        end
    end

endmodule
