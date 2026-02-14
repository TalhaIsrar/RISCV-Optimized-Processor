module mul_unit (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,

    input  logic [1:0]  mul_op,
    // 00 = MUL
    // 01 = MULH
    // 10 = MULHSU
    // 11 = MULHU

    input  logic [31:0] rs1,
    input  logic [31:0] rs2,

    output logic [31:0] result,
    output logic        done,
    output logic        busy
);

    // Registered operands to shorten critical path
    logic signed [32:0] op_a_r;
    logic signed [32:0] op_b_r;
    logic [1:0]         mul_op_r;

    // Extend operands combinationally
    logic signed [32:0] op_a_comb;
    logic signed [32:0] op_b_comb;

    logic signed [65:0] product;

    always_comb begin
        case (mul_op)
            2'b00, 2'b01: begin           // MUL / MULH
                op_a_comb = {rs1[31], rs1};
                op_b_comb = {rs2[31], rs2};
            end
            2'b10: begin                  // MULHSU
                op_a_comb = {rs1[31], rs1};
                op_b_comb = {1'b0, rs2};
            end
            2'b11: begin                  // MULHU
                op_a_comb = {1'b0, rs1};
                op_b_comb = {1'b0, rs2};
            end
            default: begin
                op_a_comb = 33'd0;
                op_b_comb = 33'd0;
            end
        endcase
    end

    // Register operands and opcode
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            op_a_r   <= 33'd0;
            op_b_r   <= 33'd0;
            mul_op_r <= 2'd0;
            done   <= 1'b0;
            busy   <= 1'b0;
        end
        else begin
            done <= 1'b0; // default
            busy   <= 1'b0;

            if (start) begin
                op_a_r   <= op_a_comb;
                op_b_r   <= op_b_comb;
                mul_op_r <= mul_op;
                done <= 1'b1;
            end
        end
    end

    // Combinational product
    assign product = op_a_r * op_b_r;
    assign result = (mul_op_r == 2'b00) ? product[31:0] : product[63:32];


endmodule
