module tage_top #(
    parameter GHR_SIZE = 128,
    parameter N_TABLES = 4,
    parameter BIMODAL_IDX = 11,
    parameter TAGE_IDX_SIZE = 9,
    parameter TAGE_TAG_SIZE = 9
)(
    input  logic         clk,
    input  logic         rst,
    input  logic [31:0]  pc_next_pred_i,
    input  logic [31:0]  pc_pred_i,  // IF-stage PC for prediction
    input  logic [31:0]  pc_ex,  // EX-stage PC for prediction
    input  logic [31:0]  pc_upd_i,    // MEM-stage PC for update
    input  logic         br_resolved_i,
    input  logic         br_taken_i,     // EX stage actual outcome
    input  logic         update_i,       // EX stage enable update
    input  logic [GHR_SIZE-1:0] ghr_out,

    //pipeline inputs for updating
    input  logic [N_TABLES-1:0] tag_hits_in,
    input  logic [N_TABLES-1:0] u_bits_in,
    input  logic [$clog2(N_TABLES)-1:0] provider_table_in,
    input  logic [$clog2(N_TABLES)-1:0] alloc_table_in,
    input  logic [GHR_SIZE-1:0] ghr_ex,
    input  logic [GHR_SIZE-1:0] ghr_mem,

    // Outputs
    output logic         pred_o,
    output logic [N_TABLES-1:0] tag_hits,
    output logic [N_TABLES-1:0] u_bits,
    output logic [$clog2(N_TABLES)-1:0] provider_table,
    output logic [$clog2(N_TABLES)-1:0] alloc_table
);
    logic base_pred;

    // Folded histories
    logic [TAGE_IDX_SIZE-1:0] folded_idx [N_TABLES-1:0];
    logic [TAGE_TAG_SIZE-1:0] folded_tag [N_TABLES-1:0];
    logic [TAGE_IDX_SIZE-1:0] update_folded_idx [N_TABLES-1:0];
    logic [TAGE_TAG_SIZE-1:0] update_folded_tag [N_TABLES-1:0];
    logic [TAGE_IDX_SIZE-1:0] write_folded_idx [N_TABLES-1:0];
    genvar i;

    logic mispred;
    logic provider_correct;
    logic do_alloc;
    logic provider_pred_ex;

    logic [N_TABLES-1:0] table_preds;
    logic found;
    logic alloc_found;

    logic [$clog2(N_TABLES)-1:0] rr_ptr;

    // Base predictor (BHT)
    bimodal_base #(.BIMODAL_IDX(BIMODAL_IDX)) base_bht (
        .clk(clk),
        .rst(rst),
        .index_next_i(pc_next_pred_i[BIMODAL_IDX-1:0]),
        .index_i(pc_pred_i[BIMODAL_IDX-1:0]),       // index into BHT
        .pred_o(base_pred),
        .update_i(update_i),        // enable update
        .update_index_next_i(pc_ex[BIMODAL_IDX-1:0]),
        .update_index_i(pc_upd_i[BIMODAL_IDX-1:0]),// same index for update
        .taken_i(br_taken_i)        // actual branch outcome
    );

    generate
        for (i = 0; i < N_TABLES; i=i+1) begin : fold_tables
            // Read
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(TAGE_IDX_SIZE),
                .HIST_SIZE_TO_USE((i+1)*10)
            ) fh_idx (
                .ghr(ghr_out),
                .folded_history(folded_idx[i])
            );

            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(TAGE_TAG_SIZE),
                .HIST_SIZE_TO_USE((i+1)*10)
            ) fh_tag_update (
                .ghr(ghr_out),
                .folded_history(folded_tag[i])
            );

            // Update
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(TAGE_IDX_SIZE),
                .HIST_SIZE_TO_USE((i+1)*10)
            ) fh_idx_update (
                .ghr(ghr_ex),
                .folded_history(update_folded_idx[i])
            );

            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(TAGE_TAG_SIZE),
                .HIST_SIZE_TO_USE((i+1)*10)
            ) fh_tag (
                .ghr(ghr_ex),
                .folded_history(update_folded_tag[i])
            );

            // Update
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(TAGE_IDX_SIZE),
                .HIST_SIZE_TO_USE((i+1)*10)
            ) fh_idx_update_mem (
                .ghr(ghr_mem),
                .folded_history(write_folded_idx[i])
            );


        end
    endgenerate

    always_comb begin
        if (tag_hits_in != 0)
            provider_pred_ex = table_preds[provider_table_in];
        else
            provider_pred_ex = base_pred;

        mispred = (provider_pred_ex != br_taken_i);
        provider_correct = !mispred;

        do_alloc = update_i && mispred;
    end

    // Tagged tables
    generate
        for (i = 0; i < N_TABLES; i=i+1) begin : tables
            tage_table #(.TAGE_IDX_SIZE(TAGE_IDX_SIZE), .TAGE_TAG_SIZE(TAGE_TAG_SIZE)) t (
                .clk(clk),
                .rst(rst),

                // IF-stage prediction
                .index_i(pc_next_pred_i[TAGE_IDX_SIZE+1:2] ^ folded_idx[i]),
                .tag_i(pc_next_pred_i[TAGE_TAG_SIZE+TAGE_IDX_SIZE+1:TAGE_IDX_SIZE+2] ^ folded_tag[i]),
                .hit_o(tag_hits[i]),
                .pred_o(table_preds[i]),
                .u_o(u_bits[i]),

                // EX-stage update using pipelined signals
                .update_i(update_i && (i == provider_table_in)),
                .alloc_i(do_alloc && (i == alloc_table_in)),
                .taken_i(br_taken_i),
                .set_u_i(update_i && provider_correct && (i == provider_table_in)),
                .clr_u_i(update_i && mispred && (i == provider_table_in)),
                .update_index_i(pc_ex[TAGE_IDX_SIZE+1:2] ^ update_folded_idx[i]),
                .update_tag_i(pc_ex[TAGE_TAG_SIZE+TAGE_IDX_SIZE+1:TAGE_IDX_SIZE+2] ^ update_folded_tag[i]),
                .write_index_i(pc_upd_i[TAGE_IDX_SIZE+1:2] ^ write_folded_idx[i])
            );
        end
    endgenerate

    // Choose prediction
    // pick longest matching table
    always_comb begin
        pred_o = base_pred;
        provider_table = 0;
        found = 0;
        for (int j = N_TABLES-1; j >= 0; j=j-1) begin
            if (tag_hits[j] && !found) begin
                provider_table = j[$clog2(N_TABLES)-1:0];
                pred_o = table_preds[j];
                found = 1;
            end
        end
    end

    always_comb begin
        alloc_found = 0;
        alloc_table = '0;
        for (int j = 0; j < N_TABLES; j=j+1) begin
            if (!tag_hits[j] && u_bits[j] == 1'b0 && !alloc_found) begin
                alloc_table = j[$clog2(N_TABLES)-1:0];  
                alloc_found = 1;
            end
        end
        if (!alloc_found) begin
            alloc_table = 0;
        end
    end


endmodule
