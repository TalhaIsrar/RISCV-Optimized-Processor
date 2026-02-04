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
    logic [N-1:0] update_bits;

    always_comb begin
        read_mask   = (1'b1 << index);
        write_mask  = (1'b1 << update_index);

        // Combine all bits we want to update
        update_mask = read_mask | write_mask;

        // Build the new values to set
        update_bits = (update_lru_read  && valid  ? read_mask  : '0)
                    | (update_lru_write && update ? write_mask : '0);

        // Apply updates
        next_LRU = (LRU & ~update_mask) | update_bits;
    end

endmodule