module instruction_mem(
    input logic clk,
    input logic rst,
    input logic [31:0] pc,
    input logic read_en,
    input logic write_en,
    input logic flush,
    input logic [13:0] write_addr,
    input logic [31:0] write_data,
    output logic [31:0] instruction
);

    // Memory array to hold instructions
    logic [31:0] mem [0:16383]; // 64KB memory

    // Initialize memory using file
    initial begin
        $readmemh("code.mem",mem);
    end

    // Add this for synthesis to block RAM
    always_ff @(posedge clk) begin
        if (write_en) 
            mem[write_addr] <= write_data;
    end

    always_ff @(posedge clk) begin
        if (rst || flush) begin
            instruction <= 32'h00000000; // Reset instruction to NOP
        end else if (read_en) begin
            instruction <= mem[pc[15:2]]; // Fetch instruction based on PC
        end
    end
endmodule