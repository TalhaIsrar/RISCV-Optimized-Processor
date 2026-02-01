module lru_next(
    input logic [3:0] index,
    input logic [3:0] update_index,
    input logic update_lru_read,
    input logic update_lru_write,
    input logic valid,
    input logic update,
    input logic [15:0] LRU,
    output logic [15:0] next_LRU
);

    // One-hot masks for read and write
    logic [15:0] read_mask;
    logic [15:0] write_mask;
    logic [15:0] update_mask;
    logic [15:0] update_bits;

    always_comb begin
        read_mask   = (16'b1 << index);
        write_mask  = (16'b1 << update_index);

        // Combine all bits we want to update
        update_mask = read_mask | write_mask;

        // Build the new values to set
        update_bits = (update_lru_read  && valid  ? read_mask  : 16'b0)
                    | (update_lru_write && update ? write_mask : 16'b0);

        // Apply updates
        next_LRU = (LRU & ~update_mask) | update_bits;
    end

endmodule