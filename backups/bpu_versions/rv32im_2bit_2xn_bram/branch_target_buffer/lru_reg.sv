module lru_reg #(parameter N = 32)(
    input logic clk,
    input logic rst,
    input logic [N-1:0] LRU_updated,

    output logic [N-1:0] LRU
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            LRU <= '0; // Reset LRU to 0
        end else begin
            LRU <= LRU_updated;
        end
    end

endmodule