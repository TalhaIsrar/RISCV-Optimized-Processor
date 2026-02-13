module ex_mem_pipeline(
    input logic clk,
    input logic rst,
    input logic pipeline_flush,
    input logic pipeline_en,

    input logic [31:0] ex_result,
    input logic [31:0] ex_op2_selected,
    input logic ex_memory_write,
    input logic [2:0] ex_memory_load_type,
    input logic ex_wb_load,
    input logic ex_wb_reg_file,
    input logic [4:0] ex_wb_rd,

    input logic [31:0] ex_predicted_pc,
    input logic ex_pred_valid,
    input logic [31:0] ex_pc,
    input logic [31:0] ex_immediate,
    input logic [2:0] ex_func3,
    input logic [2:0] ex_alu_flags,
    input logic ex_predictedTaken,
    input logic [8:0] ex_decoded_instruction,
    input logic [31:0] ex_op1_selected,

    output logic [31:0] mem_result,
    output logic [31:0] mem_op2_selected,
    output logic mem_memory_write,
    output logic [2:0] mem_memory_load_type,
    output logic mem_wb_load,
    output logic mem_wb_reg_file,
    output logic [4:0] mem_wb_rd,

    output logic [31:0] mem_predicted_pc,
    output logic mem_pred_valid,
    output logic [31:0] mem_pc,
    output logic [31:0] mem_immediate,
    output logic [2:0] mem_func3,
    output logic [2:0] mem_alu_flags,
    output logic mem_predictedTaken,
    output logic [8:0] mem_decoded_instruction,
    output logic [31:0] mem_op1_selected
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            mem_result <= 32'h00000000;
            mem_op2_selected <= 32'h00000000;
            mem_memory_write <= 1'b0;
            mem_memory_load_type <= 3'b111;
            mem_wb_load <= 1'b0;
            mem_wb_reg_file <= 1'b0;
            mem_wb_rd <= 5'b00000;  
            mem_predicted_pc <= 0;
            mem_pred_valid <= 0;
            mem_pc <= 0;
            mem_immediate <= 0;
            mem_func3 <= 0;
            mem_alu_flags <= 0;
            mem_predictedTaken <= 0;
            mem_decoded_instruction <= 0;
            mem_op1_selected <= 0;
            
        end else if (pipeline_flush) begin      
            mem_result <= 32'h00000000;
            mem_op2_selected <= 32'h00000000;
            mem_memory_write <= 1'b0;
            mem_memory_load_type <= 3'b111;
            mem_wb_load <= 1'b0;
            mem_wb_reg_file <= 1'b0;
            mem_wb_rd <= 5'b00000;  
            mem_predicted_pc <= 0;
            mem_pred_valid <= 0;
            mem_pc <= 0;
            mem_immediate <= 0;
            mem_func3 <= 0;
            mem_alu_flags <= 0;
            mem_predictedTaken <= 0;
            mem_decoded_instruction <= 0;
            mem_op1_selected <= 0;

        end else begin
            mem_result <= ex_result;
            mem_op2_selected <= ex_op2_selected;
            mem_memory_write <= ex_memory_write;
            mem_memory_load_type <= ex_memory_load_type;
            mem_wb_load <= ex_wb_load;
            mem_wb_reg_file <= ex_wb_reg_file;
            mem_wb_rd <= ex_wb_rd;
            mem_predicted_pc <= ex_predicted_pc;
            mem_pred_valid <= ex_pred_valid;
            mem_pc <= ex_pc;
            mem_immediate <= ex_immediate;
            mem_func3 <= ex_func3;
            mem_alu_flags <= ex_alu_flags;
            mem_predictedTaken <= ex_predictedTaken;
            mem_decoded_instruction <= ex_decoded_instruction;
            mem_op1_selected <= ex_op1_selected;
        end
    end

endmodule