module ghr #(
    parameter GHR_SIZE = 64
)(
    input  logic clk,
    input  logic rst,

    // IF stage speculative update
    input  logic update_if,
    input  logic taken_if,

    // EX stage resolution
    input  logic update_final,
    input  logic taken_final,
    input  logic mis_prediction,

    output logic [GHR_SIZE-1:0] history_o
);

    logic [GHR_SIZE-1:0] history;
    logic [GHR_SIZE-1:0] checkpoint;

    always_ff @(posedge clk) begin
        if (rst) begin
            history    <= '0;
            checkpoint <= '0;
        end
        else begin
            // On resolution (EX stage)
            if (update_final && mis_prediction) begin
                history <= {checkpoint[GHR_SIZE-2:0], taken_final};
            end else if (update_if) begin
                // On prediction (IF stage)
                checkpoint <= history;  // save snapshot
                history    <= {history[GHR_SIZE-2:0], taken_if};
            end
        end
    end

    assign history_o = history;

endmodule
