module btb #(parameter M = 64, parameter N = 8)(   // Modify N to change the size of BTB
    input logic clk,
    input logic rst,
    input logic [31:0] pc,
    input logic [31:0] update_pc,
    input logic update,
    
    input logic [31:0] update_target,
    input logic mispredicted,

    output logic [31:0] target_pc,
    output logic valid,
    output logic predictedTaken
);

    // Read Signals
    wire [$clog2(N)-1:0] read_index;
    wire [29-$clog2(N):0] read_tag;
    wire [M-1:0] read_set;

    // Update Signals
    wire [$clog2(N)-1:0] update_index;
    wire [29-$clog2(N):0] update_tag;
    wire [M-1:0] update_set;  
    wire [M-1:0] write_set;

    // LRU Signals
    wire [N-1:0] LRU, next_LRU;
    wire next_LRU_read;
    wire next_LRU_write;

    // Added a cycle delay in update signal
    logic reg_file_write;
    logic [M-1:0] reg_write_set;
    logic [$clog2(N)-1:0] reg_write_index;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_file_write <= 0;
            reg_write_set <= 0;
            reg_write_index <= 0;
        end else begin
            reg_file_write <= update;  // delayed by 1 cycle
            reg_write_set <= write_set;
            reg_write_index <= update_index;
        end
    end


    // PC (32 bits) = Tag (27 bits) + Index (3 bits) + Byte offset (2 bits)
    assign read_index = pc[$clog2(N)+1:2];
    assign read_tag = pc[31:$clog2(N)+2];

    assign update_index = update_pc[$clog2(N)+1:2];
    assign update_tag = update_pc[31:$clog2(N)+2];

    btb_file #(.M(M), .N(N)) btb_file_inst(
        .clk(clk),
        .read_index(read_index),
        .update_index(update_index),
        .write_index(reg_write_index),
        .write_set(reg_write_set),
        .write_en(reg_file_write),
        .read_set(read_set),
        .update_set(update_set)
    );

    btb_read #(.M(M), .N(N)) btb_read_inst(
        .read_set(read_set),
        .read_tag(read_tag),
        .read_index(read_index),
        .valid(valid),
        .predictedTaken(predictedTaken),
        .target(target_pc)
    );

    btb_write #(.M(M), .N(N)) btb_write_inst(
        .update_set(update_set),
        .update_tag(update_tag),
        .update_index(update_index),
        .update_target(update_target),
        .mispredicted(mispredicted),
        .write_set(write_set)
    );

endmodule