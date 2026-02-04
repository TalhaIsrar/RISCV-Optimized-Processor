module btb_file #(parameter M = 128, parameter N = 32)(
    input logic clk,
    input logic [$clog2(N)-1:0] read_index, // 2^3 = 8 possible sets
    input logic [$clog2(N)-1:0] update_index,
    input logic [$clog2(N)-1:0] write_index,
    input logic [M-1:0] write_set,
    input logic write_en,

    output [M-1:0] read_set,
    output [M-1:0] update_set  
);

    logic [M-1:0] file [N-1:0]; // Change from [7:0] to [0:7]

    // Not practical way but here we keep
    integer i;
    initial begin
        for (i = 0; i < N; i = i + 1)
            file[i] = M'(0);
    end

    // Write operation
    always_ff @(posedge clk) begin
        if (write_en)
            file[write_index] <= write_set;
    end

    // Read operation
    assign update_set = file[update_index];

    // In case read and write are to same address (when write enable = 1):
    // Forward write value to read set directly to save 1 cycle
    assign read_set = ((read_index == write_index) && write_en) ? write_set : file[read_index];

endmodule