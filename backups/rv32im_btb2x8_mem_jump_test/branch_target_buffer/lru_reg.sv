module lru_reg(
    input logic clk,
    input logic rst,
    input logic [7:0] LRU_updated,

    output logic [7:0] LRU
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            LRU <= 8'h00; // Reset LRU to 0
        end else begin
            LRU <= LRU_updated;
        end
    end

endmodule