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

    output logic [31:0] mem_result,
    output logic [31:0] mem_op2_selected,
    output logic mem_memory_write,
    output logic [2:0] mem_memory_load_type,
    output logic mem_wb_load,
    output logic mem_wb_reg_file,
    output logic [4:0] mem_wb_rd
);

    always_ff @(posedge clk) begin
        if (rst || pipeline_flush) begin
            mem_result <= 32'h00000000;
            mem_op2_selected <= 32'h00000000;
            mem_memory_write <= 1'b0;
            mem_memory_load_type <= 3'b111;
            mem_wb_load <= 1'b0;
            mem_wb_reg_file <= 1'b0;
            mem_wb_rd <= 5'b00000;           
        end else if (pipeline_en) begin
            mem_result <= ex_result;
            mem_op2_selected <= ex_op2_selected;
            mem_memory_write <= ex_memory_write;
            mem_memory_load_type <= ex_memory_load_type;
            mem_wb_load <= ex_wb_load;
            mem_wb_reg_file <= ex_wb_reg_file;
            mem_wb_rd <= ex_wb_rd;
        end
    end

endmodule