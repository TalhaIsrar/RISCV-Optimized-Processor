module id_ex_pipeline(
    input logic clk,
    input logic rst,
    input logic pipeline_flush,
    input logic pipeline_en,

    input logic [31:0] id_instruction,
    input logic [31:0] id_pc,
    input logic [31:0] id_op1,
    input logic [31:0] id_op2,
    input logic [31:0] id_immediate,
    input logic id_alu_src,
    input logic [6:0]  id_func7,
    input logic [2:0]  id_func3,
    input logic id_s_type_inst,
    input logic id_wb_load,
    input logic id_wb_reg_file,
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [4:0] id_wb_rd,
    input logic id_pred_taken,
    input logic [31:0] id_predicted_pc,
    input logic id_pred_valid,
    input logic [8:0] id_decoded_instruction,
    input logic id_m_type_inst,

    output logic ex_forward_pipeline_flush,
    output logic [31:0] ex_instruction,
    output logic [31:0] ex_pc,
    output logic [31:0] ex_op1,
    output logic [31:0] ex_op2,
    output logic [31:0] ex_immediate,
    output logic ex_alu_src,
    output logic [6:0] ex_func7,
    output logic [2:0] ex_func3,
    output logic ex_s_type_inst,
    output logic ex_wb_load,
    output logic ex_wb_reg_file,
    output logic [4:0] ex_rs1,
    output logic [4:0] ex_rs2,
    output logic [4:0] ex_wb_rd,
    output logic ex_pred_taken,
    output logic [31:0] ex_predicted_pc,
    output logic ex_pred_valid,
    output logic [8:0] ex_decoded_instruction,
    output logic ex_m_type_inst
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            ex_instruction <= 0;
            ex_pc <= 0;
            ex_op1 <= 0;
            ex_op2 <= 0;
            ex_immediate <= 0;
            ex_alu_src <= 1'b1;
            ex_func7 <= 0;
            ex_func3 <= 0;
            ex_s_type_inst <= 0;
            ex_wb_load <= 0;
            ex_wb_reg_file <= 0;
            ex_wb_rd <= 0;
            ex_rs1 <= 0;
            ex_rs2 <= 0;
            ex_pred_taken <= 0;
            ex_predicted_pc <= 0;
            ex_forward_pipeline_flush <= 1'b1;;
            ex_pred_valid <= 0;
            ex_decoded_instruction <= 0;
            ex_m_type_inst <= 0;
        end else if (pipeline_flush) begin
            ex_instruction <= 0;
            ex_pc <= 0;
            ex_op1 <= 0;
            ex_op2 <= 0;
            ex_immediate <= 0;
            ex_alu_src <= 1'b1;
            ex_func7 <= 0;
            ex_func3 <= 0;
            ex_s_type_inst <= 0;
            ex_wb_load <= 0;
            ex_wb_reg_file <= 0;
            ex_wb_rd <= 0;
            ex_rs1 <= 0;
            ex_rs2 <= 0;
            ex_pred_taken <= 0;
            ex_predicted_pc <= 0;
            ex_forward_pipeline_flush <= 1'b1;;
            ex_pred_valid <= 0;
            ex_decoded_instruction <= 0;
            ex_m_type_inst <= 0;
        end else if (pipeline_en) begin
            ex_instruction <= id_instruction;
            ex_pc <= id_pc;
            ex_op1 <= id_op1;
            ex_op2 <= id_op2;
            ex_immediate <= id_immediate;
            ex_alu_src <= id_alu_src;
            ex_func7 <= id_func7;
            ex_func3 <= id_func3;
            ex_s_type_inst <= id_s_type_inst;
            ex_wb_load <= id_wb_load;
            ex_wb_reg_file <= id_wb_reg_file;
            ex_wb_rd <= id_wb_rd;
            ex_rs1 <= id_rs1;
            ex_rs2 <= id_rs2;
            ex_pred_taken <= id_pred_taken;
            ex_forward_pipeline_flush <= 1'b0;
            ex_predicted_pc <= id_predicted_pc;
            ex_pred_valid <= id_pred_valid;
            ex_decoded_instruction <= id_decoded_instruction;
            ex_m_type_inst <= id_m_type_inst;
        end
    end

endmodule