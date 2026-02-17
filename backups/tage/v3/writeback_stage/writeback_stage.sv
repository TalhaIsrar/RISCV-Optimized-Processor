module writeback_stage(
    input logic wb_load,
    input logic [31:0] mem_read_data,
    input logic [31:0] alu_result,

    output logic [31:0] wb_result
);
    assign wb_result = wb_load ? mem_read_data : alu_result;

endmodule