module bimodal_base #(
    parameter BIMODAL_IDX = 10   // 1024 entries default
)(
    input  logic                clk,
    input  logic                rst,

    // Prediction (IF stage)
    input  logic [BIMODAL_IDX-1:0]     index_i,
    output logic                pred_o,

    // Update
    input  logic                update_i,
    input  logic [BIMODAL_IDX-1:0]     update_index_i,
    input  logic                taken_i
);

    localparam ENTRIES = (1 << BIMODAL_IDX);

    // 2-bit counters
    logic [1:0] bimodel_table [ENTRIES-1:0];

    integer i;

    // Reset
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < ENTRIES; i++) begin
                bimodel_table[i] <= 2'b01;  // weak NOT TAKEN
            end
        end
    end

    // Prediction (combinational read)
    assign pred_o = bimodel_table[index_i][1];

    always_ff @(posedge clk) begin
        if (update_i) begin
            if (taken_i && bimodel_table[update_index_i] != 2'b11)  // increment
                bimodel_table[update_index_i] <= bimodel_table[update_index_i] + 1;
            else if (!taken_i && bimodel_table[update_index_i] != 2'b00) // decrement
                bimodel_table[update_index_i] <= bimodel_table[update_index_i] - 1;
        end
    end

endmodule
