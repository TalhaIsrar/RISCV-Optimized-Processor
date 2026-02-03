module lru_next(
    input logic [2:0] index,
    input logic [2:0] update_index,
    input logic update_lru_read,
    input logic update_lru_write,
    input logic valid,
    input logic update,
    input logic [7:0] LRU,
    output logic [7:0] next_LRU
);

    // One-hot masks for read and write
    logic [7:0] read_mask;
    logic [7:0] write_mask;
    logic [7:0] update_mask;
    logic [7:0] update_write, update_read, update_bits;

    logic write_LRU_bit;
    logic read_LRU_bit;

    logic [7:0] LRU_mask;

    always_comb begin
        read_mask   = valid ? (8'b00000001 << index) : 8'b00000000;
        write_mask  = update ? (8'b00000001 << update_index) : 8'b00000000;

        // Combine all bits we want to update
        update_mask = read_mask | write_mask;

        LRU_mask = LRU & ~(update_mask);

        write_LRU_bit = update ? update_lru_write : LRU[update_index];
        read_LRU_bit = update_lru_read;

        update_read = {7'b0, read_LRU_bit} << index;
        update_write = {7'b0, write_LRU_bit} << update_index;
        update_bits = update_read | update_write;

        // Apply updates
        next_LRU = LRU_mask | update_bits;
    end

endmodule