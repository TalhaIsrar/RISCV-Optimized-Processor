module mem_wb_pipeline(
    input logic clk,
    input logic rst,
    input logic pipeline_en,
    input logic mem_wb_load,
    input logic mem_wb_reg_file,
    input logic [31:0] mem_read_data,
    input logic [31:0] mem_calculated_result,
    input logic [4:0] mem_wb_rd,

    output logic wb_load,
    output logic wb_reg_file,
    output logic [31:0] wb_read_data,
    output logic [31:0] wb_calculated_result,
    output logic [4:0] wb_rd
);

    always_ff @(posedge clk) begin
        if (rst) begin
            wb_load <= 0;
            wb_reg_file <= 0;
            wb_calculated_result <= 0;
            wb_rd <= 0;
        end else begin
            wb_load <= mem_wb_load;
            wb_reg_file <= mem_wb_reg_file;
            wb_calculated_result <= mem_calculated_result;
            wb_rd <= mem_wb_rd;
        end
    end

    assign wb_read_data = mem_read_data;

endmodule