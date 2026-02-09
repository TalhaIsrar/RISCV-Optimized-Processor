module m_operand_logic(
    input logic [31:0] op1_m_unit,
    input logic [31:0] op2_m_unit,    

    input logic op1_signed,
    input logic op2_signed,

    output logic signed[32:0] op1_m_alu,
    output logic signed[32:0] op2_m_alu   
);

    assign op1_m_alu = op1_signed ? {op1_m_unit[31], op1_m_unit} : {1'b0, op1_m_unit};
    assign op2_m_alu = op2_signed ? {op2_m_unit[31], op2_m_unit} : {1'b0, op2_m_unit};

endmodule