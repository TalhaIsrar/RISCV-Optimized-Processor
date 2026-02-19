module fold_history #(
    parameter GHR_SIZE        = 128,   // total width of global history
    parameter FOLDED_HIST_SIZE = 8,    // output folded history width
    parameter HIST_SIZE_TO_USE = 11    // number of recent bits to use for folding
)(
    input  logic [GHR_SIZE-1:0] ghr,
    output logic [FOLDED_HIST_SIZE-1:0] folded_history
);

    // internal variables
    integer i;
    logic [FOLDED_HIST_SIZE-1:0] temp;

    always_comb begin
        temp = '0;
        // Fold only the most recent HIST_SIZE_TO_USE bits
        for (i = 0; i < HIST_SIZE_TO_USE; i=i+1) begin
            // XOR each bit into folded_history using modulo to wrap around output width
            temp[i % FOLDED_HIST_SIZE] = temp[i % FOLDED_HIST_SIZE] ^ ghr[i];
        end
        folded_history = temp;
    end

endmodule
