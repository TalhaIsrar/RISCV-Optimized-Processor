module tage_top #(
    parameter GHR_SIZE = 128,
    parameter N_TABLES = 4
)(
    input  logic         clk,
    input  logic         rst,
    input logic [31:0] pc_pred_i,  // IF-stage PC for prediction
    input logic [31:0] pc_upd_i,    // EX-stage PC for update
    input  logic         br_resolved_i,
    input  logic         br_taken_i,     // EX stage actual outcome
    input  logic         update_i,       // EX stage enable update
    input  logic [GHR_SIZE-1:0] ghr_out,

    output logic         pred_o
);

    // Base predictor (BHT)
    logic base_pred;
    bimodal_base #(.IDXW(11)) base_bht (
        .clk(clk),
        .rst(rst),
        .index_i(pc_pred_i[10:0]),       // index into BHT
        .pred_o(base_pred),
        .update_i(update_i),        // enable update
        .update_index_i(pc_upd_i[10:0]),// same index for update
        .taken_i(br_taken_i)        // actual branch outcome
    );


    // Tagged tables
    // Arrays for connecting to N_TABLES instances
    logic [8:0] tag_hits;
    logic [2:0] table_preds;
    logic [2:0] u_bits;

    // Example parameters
    localparam IDXW = 9;
    localparam TAGW = 9;

    // folded histories for index and tag
    logic [IDXW-1:0] folded_idx [N_TABLES-1:0];
    logic [TAGW-1:0] folded_tag [N_TABLES-1:0];


    genvar i;
    generate
        for (i = 0; i < N_TABLES; i=i+1) begin : fold_tables
            // folded history for index
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(IDXW),
                .HIST_SIZE_TO_USE((i+1)*10)   // example: use 10 recent bits
            ) fh_idx (
                .ghr(ghr_out),
                .folded_history(folded_idx[i])
            );

            // folded history for tag
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(TAGW),
                .HIST_SIZE_TO_USE((i+1)*10)    // example: use 8 recent bits
            ) fh_tag (
                .ghr(ghr_out),
                .folded_history(folded_tag[i])
            );

            tage_table #(.IDXW(IDXW), .TAGW(TAGW)) t (
                .clk(clk),
                .rst(rst),

                // IF-stage prediction
                .index_i(pc_pred_i[IDXW+1:2] ^ folded_idx[i]),
                .tag_i(pc_pred_i[19:11] ^ folded_tag[i]),

                .hit_o(tag_hits[i]),
                .pred_o(table_preds[i]),
                .u_o(u_bits[i]),

                // EX-stage update
                .update_i(update_i),
                .alloc_i(1'b1),  // allocation logic
                .taken_i(br_taken_i),
                .set_u_i(1'b0),
                .clr_u_i(1'b0),
                .update_index_i(pc_upd_i[IDXW+1:2] ^ folded_idx[i]),
                .update_tag_i(pc_upd_i[19:11] ^ folded_tag[i])
            );

        end
    endgenerate



    // Choose prediction
    // pick longest matching table
    logic found;
    always_comb begin
        pred_o = base_pred;
        found = 0;
        for (int j = N_TABLES-1; j >= 0; j=j-1) begin
            if (tag_hits[j] && !found) begin
                pred_o = table_preds[j];
                found = 1;
            end
        end
    end

endmodule
