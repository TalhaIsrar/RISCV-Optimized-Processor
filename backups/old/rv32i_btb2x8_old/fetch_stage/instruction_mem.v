module instruction_mem(
    input clk,
    input rst,
    input [31:0] pc,
    input read_en,
    input write_en,
    input flush,
    input [15:0] write_addr,
    input [31:0] write_data,
    output reg [31:0] instruction
);

    // Memory array to hold instructions
    reg [31:0] mem [0:65535]; // 64KB memory

    // Initialize memory using file
    initial begin
        $readmemh("code.mem",mem);
    end

    // Add this for synthesis to block RAM
    always @(posedge clk) begin
        if (write_en) 
            mem[write_addr] <= write_data;
    end

    always @(posedge clk) begin
        if (rst || flush) begin
            instruction <= 32'h00000000; // Reset instruction to NOP
        end else if (read_en) begin
            instruction <= mem[pc[17:2]]; // Fetch instruction based on PC
        end
    end
endmodule