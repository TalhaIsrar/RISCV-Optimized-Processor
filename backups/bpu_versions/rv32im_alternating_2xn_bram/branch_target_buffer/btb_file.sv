module btb_file #(parameter N = 32)(
    input logic clk,
    input logic rst,
    input logic [$clog2(N)-1:0] read_index, 
    input logic [$clog2(N)-1:0] update_index,
    input logic [$clog2(N)-1:0] write_index,
    input logic [127:0] write_set,
    input logic write_en,

    output logic [127:0] read_set,
    output logic [127:0] update_set  
);

    (* ram_style = "block" *) logic [127:0] file1 [N-1:0]; 
    (* ram_style = "block" *) logic [127:0] file2 [N-1:0]; 

    logic [127:0] read_set_temp, update_set_temp;

    logic [$clog2(N)-1:0] read_index_delay, write_index_delay, update_index_delay;
    logic [127:0] write_set_delay;
    logic write_en_delay;
    
    // Not practical way but here we keep
    integer i;
    initial begin
        for (i = 0; i < N; i = i + 1)
            file1[i] = 128'h0;
            file2[i] = 128'h0;
    end

    // Write operation
    always_ff @(posedge clk) begin
        if (write_en) begin
            file1[write_index] <= write_set;
            file2[write_index] <= write_set;
        end
    end

    always_ff @(posedge clk) begin
        read_set_temp <= file1[read_index];
        update_set_temp <= file2[update_index];
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            read_index_delay <= 0;
            write_index_delay <= 0;
            update_index_delay <= 0;
            write_set_delay <= 0;
            write_en_delay <= 0;
        end else begin
            read_index_delay <= read_index;
            write_index_delay <= write_index;
            update_index_delay <= update_index;
            write_set_delay <= write_set;
            write_en_delay <= write_en;
        end
    end

    assign read_set = ((read_index_delay == write_index_delay) && write_en_delay) ? write_set_delay : read_set_temp;
    assign update_set = ((update_index_delay == write_index_delay) && write_en_delay) ? write_set_delay : update_set_temp;
    // Read operation
    // In case read and write are to same address (when write enable = 1):
    // Forward write value to read set directly to save 1 cycle

endmodule