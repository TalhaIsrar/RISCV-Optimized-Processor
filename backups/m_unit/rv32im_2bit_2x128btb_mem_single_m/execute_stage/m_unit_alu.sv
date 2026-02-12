`include "m_definitions.svh"

module m_unit_alu(
    input logic signed[32:0] op1_m_alu,
    input logic signed[32:0] op2_m_alu,
    input logic [2:0] m_alu_control,
    input logic mulh,
    input logic op1_signed,
    output logic signed [31:0] result_m_alu
);
    logic signed[65:0] mul_inst_result;
    logic [32:0] div_inst_result;
    logic [32:0] rem_inst_result;

    assign mul_inst_result = op1_m_alu * op2_m_alu;

    always_comb begin
        if (op2_m_alu[31:0] == 0) begin
            rem_inst_result = op1_m_alu;
        end else if ((op1_m_alu[31:0] == 32'h80000000 && op2_m_alu[31:0] == 32'hFFFFFFFF) && op1_signed) begin
            rem_inst_result = 33'd0;
        end else begin
            rem_inst_result = op1_m_alu % op2_m_alu;
        end
    end

    always_comb begin
        if (op2_m_alu[31:0] == 0) begin
            div_inst_result = op1_signed ? {1'b0,-32'd1} : {33{1'b1}};
        end else if ((op1_m_alu[31:0] == 32'h80000000 && op2_m_alu[31:0] == 32'hFFFFFFFF) && op1_signed) begin
            div_inst_result = op1_m_alu;
        end else begin
            div_inst_result = op1_m_alu / op2_m_alu;
        end
    end


    always_comb begin
        case (m_alu_control)
            `M_ALU_MUL: result_m_alu = mulh ? mul_inst_result[63:32] : mul_inst_result[31:0];
            `M_ALU_DIV:  result_m_alu = div_inst_result[31:0];
            `M_ALU_REM:  result_m_alu = rem_inst_result[31:0];
            `M_ALU_ZERO: result_m_alu = 32'b0;
            default:  result_m_alu = 32'b0;
        endcase
    end

endmodule