module alu(
    input logic [31:0] op1,
    input logic [31:0] op2,
    input logic [3:0] ALUControl,

    output logic [31:0] result,
    output [2:0] alu_flags
);
    wire lt_flag;   // signed comparison
    wire ltu_flag;  // unsigned comparison
    wire zero_flag;  // result == 0

    assign lt_flag = $signed(op1) < $signed(op2);
    assign ltu_flag = op1 < op2;

    always_comb begin
        case (ALUControl)
            4'b0000:  result = $signed(op1) + $signed(op2);
            4'b0001:  result = $signed(op1) - $signed(op2);
            4'b0010:  result = op1 & op2;
            4'b0011:  result = op1 | op2;
            4'b0100:  result = op1 ^ op2;
            4'b0101:  result = op1 << op2[4:0];    // Shift left logical - lower 5 bits used according to RISCV Spec
            4'b0110:  result = op1 >> op2[4:0];    // Shift right logical
            4'b0111:  result = $signed(op1) >>> op2[4:0];   // Shift right arithmetic
            4'b1000:  result = {31'd0, lt_flag};
            4'b1001:  result = {31'd0, ltu_flag};
            default:  result = 32'b0;
        endcase
    end

    assign zero_flag = (result == 32'b0);

    assign alu_flags = {lt_flag, ltu_flag, zero_flag};

endmodule