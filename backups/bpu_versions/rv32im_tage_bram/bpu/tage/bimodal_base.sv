module bimodal_base #(
    parameter BIMODAL_IDX = 10   // 1024 entries default
)(
    input  logic                clk,
    input  logic                rst,

    // Prediction (IF stage)
    input  logic [BIMODAL_IDX-1:0]     index_next_i,
    input  logic [BIMODAL_IDX-1:0]     index_i,
    output logic                pred_o,

    // Update
    input  logic                update_i,
    input  logic [BIMODAL_IDX-1:0]     update_index_next_i,
    input  logic [BIMODAL_IDX-1:0]     update_index_i,
    input  logic                taken_i
);

    localparam ENTRIES = (1 << BIMODAL_IDX);

    // 2-bit counters
    logic [1:0] bimodel_table_read [ENTRIES-1:0];
    logic [1:0] bimodel_table_update [ENTRIES-1:0];

    logic [1:0] pred_o_temp, update_o_temp;
    logic [1:0] update_o;

    // Init
    integer i;
    initial begin
        for (i = 0; i < ENTRIES; i++) begin
            bimodel_table_read[i] = 2'b01;  // weak NOT TAKEN
            bimodel_table_update[i] = 2'b01;  // weak NOT TAKEN
        end
    end

    always_ff @(posedge clk) begin
        pred_o_temp <= bimodel_table_read[index_next_i];
        update_o_temp <= bimodel_table_update[update_index_next_i];
    end
    // Prediction (combinational read)
    assign pred_o = pred_o_temp[1];

    always_comb begin
        update_o = update_o_temp;
        if (taken_i && update_o_temp != 2'b11)  // increment
            update_o = update_o_temp + 1;
        else if (!taken_i && update_o_temp != 2'b00) // decrement
            update_o = update_o_temp - 1;
    end


    always_ff @(posedge clk) begin
        if (update_i) begin
            bimodel_table_read[update_index_i] <= update_o;
            bimodel_table_update[update_index_i] <= update_o;
        end
    end

endmodule
