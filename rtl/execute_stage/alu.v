module alu(
    input [31:0] op1,
    input [31:0] op2,
    input [3:0] ALUControl,

    output reg [31:0] result,
    output lt_flag,   // signed comparison
    output ltu_flag,  // unsigned comparison
    output zero_flag  // result == 0
);
    assign lt_flag = $signed(op1) < $signed(op2);
    assign ltu_flag = op1 < op2;

    always @(*) begin
        case (ALUControl)
            4'b0000: result = $signed(op1) + $signed(op2);
            4'b0001: result = $signed(op1) - $signed(op2);
            4'b0010:  result = op1 & op2;
            4'b0011:   result = op1 | op2;
            4'b0100:  result = op1 ^ op2;
            4'b0101:  result = op1 << op2[4:0];    // Shift left logical - lower 5 bits used according to RISCV Spec
            4'b0110:  result = op1 >> op2[4:0];    // Shift right logical
            4'b0111:  result = $signed(op1) >>> op2[4:0];   // Shift right arithmetic
            4'b1000:  result = lt_flag ? 32'd1 : 32'd0;
            4'b1001: result = ltu_flag ? 32'd1 : 32'd0;
            default:  result = 32'b0;
        endcase
    end

    assign zero_flag = (result == 32'b0);

endmodule