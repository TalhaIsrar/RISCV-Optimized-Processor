module m_unit(
    input logic m_inst_valid,
    input logic [31:0] op1_m_unit,
    input logic [31:0] op2_m_unit,
    input logic [2:0] func3,
    input logic [6:0] func7,

    output logic [31:0] result_m_unit
);

    logic op1_signed, op2_signed, mulh;
    logic [2:0] m_alu_control;
    logic signed [32:0] op1_m_alu, op2_m_alu;

    m_unit_alu_control m_alu_control_inst(
        .m_inst_valid(m_inst_valid),
        .func3(func3),
        .func7(func7),
        .op1_signed(op1_signed),
        .op2_signed(op2_signed),
        .mulh(mulh),
        .m_alu_control(m_alu_control)
    );

    m_operand_logic m_operand_logic_inst(
        .op1_m_unit(op1_m_unit),
        .op2_m_unit(op2_m_unit),
        .op1_signed(op1_signed),
        .op2_signed(op2_signed),
        .op1_m_alu(op1_m_alu),
        .op2_m_alu(op2_m_alu)
    );

    m_unit_alu m_unit_alu_inst(
        .op1_m_alu(op1_m_alu),
        .op2_m_alu(op2_m_alu),
        .m_alu_control(m_alu_control),
        .mulh(mulh),
        .op1_signed(op1_signed),
        .result_m_alu(result_m_unit)
    );  


endmodule