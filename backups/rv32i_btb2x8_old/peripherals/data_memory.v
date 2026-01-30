module data_memory (
    input clk,
    input rst,
    input mem_write,       // 1 = write, 0 = read
    input [3:0] byte_en,
    input [17:0] write_addr,
    input [17:0] read_addr,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    // Declare memory as word-addressable.
    // 1KB = 1024 bytes = 256 words of 32 bits.
    // The `ram_style` attribute explicitly tells Vivado to use BRAM.
    reg [31:0] mem [0:65535];

        // Initialize memory using file
    initial begin
        $readmemh("data.mem",mem);
    end

    wire [15:0] word_write_addr = write_addr[17:2];
    wire [15:0] word_read_addr  = read_addr[17:2];


    // Implement a single, synchronous read operation.
    // This is the core of BRAM inference.
    always @(posedge clk) begin
        read_data <= mem[word_read_addr];
    end

    // Implement synchronous write with byte-enables.
    // This maps directly to BRAM's byte-write enable feature.
    always @(posedge clk) begin
        if (mem_write) begin
            if (byte_en[0]) mem[word_write_addr][7:0]   <= write_data[7:0];
            if (byte_en[1]) mem[word_write_addr][15:8]  <= write_data[15:8];
            if (byte_en[2]) mem[word_write_addr][23:16] <= write_data[23:16];
            if (byte_en[3]) mem[word_write_addr][31:24] <= write_data[31:24];
        end
    end

endmodule