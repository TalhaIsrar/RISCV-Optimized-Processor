module lru_next #(parameter N = 32)(
    input logic [$clog2(N)-1:0] index,
    input logic [$clog2(N)-1:0] update_index,
    input logic update_lru_read,
    input logic update_lru_write,
    input logic valid,
    input logic update,
    input logic [N-1:0] LRU,
    output logic [N-1:0] next_LRU
);

    // One-hot masks for read and write
    logic [N-1:0] read_mask;
    logic [N-1:0] write_mask;
    logic [N-1:0] update_mask;
    logic [N-1:0] update_write, update_read, update_bits;

    logic write_LRU_bit;
    logic read_LRU_bit;

    logic [N-1:0] LRU_mask;

    always_comb begin
        read_mask   = valid ? (N'(1) << index) : '0;
        write_mask  = update ? (N'(1) << update_index) : '0;

        // Combine all bits we want to update
        update_mask = read_mask | write_mask;

        LRU_mask = LRU & ~(update_mask);

        write_LRU_bit = update ? update_lru_write : LRU[update_index];
        read_LRU_bit = update_lru_read;

        update_read = {{(N-1){1'b0}}, read_LRU_bit} << index;
        update_write = {{(N-1){1'b0}}, write_LRU_bit} << update_index;
        update_bits = update_read | update_write;

        // Apply updates
        next_LRU = LRU_mask | update_bits;
    end

endmodule