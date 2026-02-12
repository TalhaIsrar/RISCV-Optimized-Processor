`include "m_definitions.svh"

module m_unit_alu_control(
    input logic m_inst_valid,
    input logic [2:0] func3,
    input logic [6:0] func7,
    output logic op1_signed,
    output logic op2_signed,
    output logic mulh,
    output logic [2:0] m_alu_control
);

    logic [2:0] ALUControl;

    always_comb begin
        unique case(func3)
            // For MULH both inputs should be signed
            `MULH: begin
                op1_signed = 1;
                op2_signed = 1;
                ALUControl = `M_ALU_MUL;
                mulh = 1;
            end

            // For MULHSU first input is signed and second unsigned
            `MULHSU: begin
                op1_signed = 1;
                op2_signed = 0;
                ALUControl = `M_ALU_MUL;
                mulh = 1;
            end

            `MUL: begin
                op1_signed = 0;
                op2_signed = 0;
                ALUControl = `M_ALU_MUL;
                mulh = 0;
            end

            `MULHU: begin
                op1_signed = 0;
                op2_signed = 0;
                ALUControl = `M_ALU_MUL;
                mulh = 1;
            end

            `DIV: begin
                op1_signed = 1;
                op2_signed = 1;
                ALUControl = `M_ALU_DIV;
                mulh = 0;
            end

            `DIVU: begin
                op1_signed = 0;
                op2_signed = 0;
                ALUControl = `M_ALU_DIV;
                mulh = 0;
            end

            `REM: begin
                op1_signed = 1;
                op2_signed = 1;
                ALUControl = `M_ALU_REM;
                mulh = 0;
            end

            `REMU: begin
                op1_signed = 0;
                op2_signed = 0;
                ALUControl = `M_ALU_REM;
                mulh = 0;
            end

            default: begin
                op1_signed = 0;
                op2_signed = 0;
                ALUControl = `M_ALU_ZERO;
                mulh = 0;
            end
        endcase
    end

    assign m_alu_control = m_inst_valid ? ALUControl : `M_ALU_ZERO;

endmodule