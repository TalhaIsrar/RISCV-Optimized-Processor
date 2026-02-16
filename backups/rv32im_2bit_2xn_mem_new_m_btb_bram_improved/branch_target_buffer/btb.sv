module btb #(parameter N = 1024)(      // Modify N to change the size of BTB
    input logic clk,
    input logic rst,
    input logic [31:0] pc,
    input logic [31:0] next_pc,
    input logic [31:0] next_update_pc,
    input logic [31:0] update_pc,
    input logic update,
    
    input logic [31:0] update_target,
    input logic mispredicted,
    input logic btb_jump_inst,

    output logic [31:0] target_pc,
    output logic valid,
    output logic predictedTaken
);

    // Read Signals
    wire [$clog2(N)-1:0] read_index;
    wire [29-$clog2(N):0] read_tag;
    wire [127:0] read_set;

    // Update Signals
    wire [$clog2(N)-1:0] update_index;
    wire [29-$clog2(N):0] update_tag;
    wire [127:0] update_set;  
    wire [127:0] write_set;

    // LRU Signals
    wire LRU_read, LRU_write, update_lru_read, update_lru_write;

    wire [$clog2(N)-1:0] read_index_file;
    wire [$clog2(N)-1:0] update_index_file;

    assign read_index_file = next_pc[$clog2(N)+1:2];
    assign update_index_file = next_update_pc[$clog2(N)+1:2];

    // PC (32 bits) = Tag (27 bits) + Index (3 bits) + Byte offset (2 bits)
    assign read_index = pc[$clog2(N)+1:2];
    assign read_tag = pc[31:$clog2(N)+2];

    assign update_index = update_pc[$clog2(N)+1:2];
    assign update_tag = update_pc[31:$clog2(N)+2];


    btb_file #(.N(N)) btb_file_inst(
        .clk(clk),
        .rst(rst),
        .read_index(read_index_file),
        .update_index(update_index_file),
        .write_index(update_index),
        .write_set(write_set),
        .write_en(update),
        .read_set(read_set),
        .update_set(update_set)
    );

    btb_read #(.N(N)) btb_read_inst(
        .read_set(read_set),
        .LRU(LRU_read),
        .read_tag(read_tag),
        .read_index(read_index),
        .next_LRU_read(update_lru_read),
        .valid(valid),
        .predictedTaken(predictedTaken),
        .target(target_pc)
    );

    btb_write #(.N(N)) btb_write_inst(
        .update_set(update_set),
        .LRU(LRU_write),
        .update_tag(update_tag),
        .update_index(update_index),
        .update_target(update_target),
        .mispredicted(mispredicted),
        .jump_inst(btb_jump_inst),
        .write_set(write_set),
        .next_LRU_write(update_lru_write)
    );

    lru_file #(.N(N)) lru_file_inst(
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .update(update),
        .write_index(read_index),
        .write_update_index(update_index),
        .read_index(read_index_file),
        .read_update_index(update_index_file),
        .update_lru_read(update_lru_read),
        .update_lru_write(update_lru_write),
        .read_LRU_bit(LRU_read),
        .write_LRU_bit(LRU_write)
    );

endmodule