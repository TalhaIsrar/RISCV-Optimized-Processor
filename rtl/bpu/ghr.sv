module ghr #(
    parameter GHR_SIZE = 64
)(
    input  logic            clk,
    input  logic            rst,

    // Update
    input  logic            update_i,
    input  logic            taken_i,

    // Output to predictor
    output logic [GHR_SIZE-1:0] history_o
);

    logic [GHR_SIZE-1:0] history;

    // Reset + Update
    always_ff @(posedge clk) begin
        if (rst) begin
            history <= '0;
        end
        else if (update_i) begin
            history <= {history[GHR_SIZE-2:0], taken_i};
        end
    end

    assign history_o = history;

endmodule
