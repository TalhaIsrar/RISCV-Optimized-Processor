module btb #(parameter N = 32)(
    input logic clk,
    input logic rst,

    input logic [31:0] next_if_pc,
    input logic [31:0] if_pc,
    input logic [31:0] mem_update_pc,
    input logic [31:0] update_target,
    input logic update_en,

    input logic update_uncond_inst,

    output logic [31:0] target_pc,
    output logic target_valid,
    output logic target_uncond_inst
);
    // Read Signals
    wire [$clog2(N)-1:0] next_if_pc_index;
    wire [29-$clog2(N):0] if_pc_tag;
    wire [63-$clog2(N):0] read_data;

    // Write Signals
    wire [$clog2(N)-1:0] mem_update_pc_index;
    wire [29-$clog2(N):0] mem_update_pc_tag;
    wire [63-$clog2(N):0] write_data;

    // BTB Write
    assign mem_update_pc_index = mem_update_pc[$clog2(N)+1:2];
    assign mem_update_pc_tag = mem_update_pc[31:$clog2(N)+2];
    assign write_data = {mem_update_pc_tag,update_target,1'b1,update_uncond_inst};

    // BTB Read Decode
    assign next_if_pc_index = next_if_pc[$clog2(N)+1:2];
    assign if_pc_tag = if_pc[31:$clog2(N)+2];

    btb_file #(.N(N)) btb_file_inst(
        .clk(clk),
        .rst(rst),
        .read_index(next_if_pc_index),
        .write_index(mem_update_pc_index),
        .write_en(update_en),
        .write_data(write_data),
        .read_data(read_data)
    );

    // BTB Read
    assign target_pc = read_data[33:2];
    assign target_valid = read_data[1] && (read_data[63-$clog2(N):34] == if_pc_tag);
    assign target_uncond_inst = read_data[0];

endmodule