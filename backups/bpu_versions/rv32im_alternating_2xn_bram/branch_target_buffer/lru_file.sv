module lru_file #(parameter N = 32)(
    input  logic clk,
    input  logic rst,

    input  logic valid,
    input  logic update,
    input  logic [$clog2(N)-1:0] write_index,
    input  logic [$clog2(N)-1:0] write_update_index,
    input  logic [$clog2(N)-1:0] read_index,
    input  logic [$clog2(N)-1:0] read_update_index,
    input  logic update_lru_read,
    input  logic update_lru_write,

    output logic read_LRU_bit,
    output logic write_LRU_bit
);

    (* ram_style = "block" *) logic LRU1 [N-1:0];
    (* ram_style = "block" *) logic LRU2 [N-1:0];

    logic final_write_en;
    logic [$clog2(N)-1:0] final_index;
    logic final_value;
    
    always_comb begin
        final_write_en = 0;
        final_index = 0;
        final_value = 0;
        if (valid) begin
            final_write_en = 1;
            final_index = write_index;
            final_value = update_lru_read;
        end
    
        if (update) begin
            final_write_en = 1;
            final_index = write_update_index;
            final_value = update_lru_write;
        end
    end

    always_ff @(posedge clk) begin
        if (final_write_en) begin
            LRU1[final_index] <= final_value;
            LRU2[final_index] <= final_value;
        end
    end

    always_ff @(posedge clk) begin
        read_LRU_bit  <= LRU1[read_index];
        write_LRU_bit <= LRU2[read_update_index];
    end

endmodule
