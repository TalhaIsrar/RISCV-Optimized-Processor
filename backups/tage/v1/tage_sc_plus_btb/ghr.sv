module ghr #(
    parameter HIST = 64
)(
    input  logic            clk,
    input  logic            rst,

    // Update (EX stage)
    input  logic            update_i,
    input  logic            taken_i,

    // Output to predictor
    output logic [HIST-1:0] history_o
);

    logic [HIST-1:0] history;

    // ----------------------------
    // Reset + Update
    // ----------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            history <= '0;
        end
        else if (update_i) begin
            history <= {history[HIST-2:0], taken_i};
        end
    end

    assign history_o = history;

endmodule
