module alu(
    input [31:0] op1,
    input [31:0] op2,
    input [9:0] ALUControl,

    output logic [31:0] result,
    output [2:0] alu_flags
);

    wire lt_flag = $signed(op1) < $signed(op2); // signed comparison
    wire ltu_flag = op1 < op2;                  // unsigned comparison

    always_comb begin
        result = '0;
        if (ALUControl[0]) result = $signed(op1) + $signed(op2);
        if (ALUControl[1]) result = $signed(op1) - $signed(op2);
        if (ALUControl[2]) result = op1 & op2;
        if (ALUControl[3]) result = op1 | op2;
        if (ALUControl[4]) result = op1 ^ op2;
        if (ALUControl[5]) result = op1 << op2[4:0];
        if (ALUControl[6]) result = op1 >> op2[4:0];
        if (ALUControl[7]) result = $signed(op1) >>> op2[4:0];
        if (ALUControl[8]) result = {31'd0, lt_flag};
        if (ALUControl[9]) result = {31'd0, ltu_flag};
    end
   
    wire zero_flag = (result == 32'b0); // result == 0

    assign alu_flags = {lt_flag,ltu_flag,zero_flag};

endmodule
