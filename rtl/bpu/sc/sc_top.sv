module sc_top  #(
    parameter SC_N_TABLES = 4,
    parameter SC_CTR_SIZE = 6,
    parameter GHR_SIZE = 256,
    parameter int SC_HIST_LEN [SC_N_TABLES] = '{0, 4, 10, 16},
    parameter int SC_IDX_SIZE [SC_N_TABLES] = '{9, 9, 9, 9},
    parameter int SUM_WIDTH = SC_CTR_SIZE + 4
)(
    input  logic                clk,
    input  logic                rst,
    
    input  logic [31:0]         pc_next_pred,
    input  logic                update_i,
    input  logic                actual_taken_i,

    input  logic [31:0]         pc_update_read,
    input  logic [31:0]         pc_update_write,
    input  logic [GHR_SIZE-1:0] ghr_if, 
    input  logic [GHR_SIZE-1:0] ghr_ex, 
    input  logic [GHR_SIZE-1:0] ghr_mem, 

    output logic signed [SUM_WIDTH-1:0] sc_sum_o
);
    localparam int MAX_IDX = 12;

    logic [MAX_IDX-1:0] folded_idx [SC_N_TABLES-1:0];
    logic [MAX_IDX-1:0] update_folded_idx [SC_N_TABLES-1:0];
    logic [MAX_IDX-1:0] write_folded_idx [SC_N_TABLES-1:0];

    // Counters
    logic signed [SC_CTR_SIZE-1:0] ctr_tables [SC_N_TABLES-1:0];
    logic signed [SUM_WIDTH-1:0] weighted_ctr_tables [SC_N_TABLES-1:0];

    logic signed [SUM_WIDTH-1:0] sc_sum;
    genvar i;
    genvar j;

    generate
        for (i = 0; i < SC_N_TABLES; i=i+1) begin : fold_sc_tables
            // Read
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(SC_IDX_SIZE[i]),
                .HIST_SIZE_TO_USE(SC_HIST_LEN[i])
            ) fh_idx (
                .ghr(ghr_if),
                .folded_history(folded_idx[i][SC_IDX_SIZE[i]-1:0])
            );

            // Update
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(SC_IDX_SIZE[i]),
                .HIST_SIZE_TO_USE(SC_HIST_LEN[i])
            ) fh_idx_update (
                .ghr(ghr_ex),
                .folded_history(update_folded_idx[i][SC_IDX_SIZE[i]-1:0])
            );

            // Update
            fold_history #(
                .GHR_SIZE(GHR_SIZE),
                .FOLDED_HIST_SIZE(SC_IDX_SIZE[i]),
                .HIST_SIZE_TO_USE(SC_HIST_LEN[i])
            ) fh_idx_update_mem (
                .ghr(ghr_mem),
                .folded_history(write_folded_idx[i][SC_IDX_SIZE[i]-1:0])
            );

        end
    endgenerate

    // SC tables
    generate
        for (i = 0; i < SC_N_TABLES; i=i+1) begin : sc_tables
            sc_table #(.SC_IDX_SIZE(SC_IDX_SIZE[i]), .SC_CTR_SIZE(SC_CTR_SIZE)) t (
                .clk(clk),
                .rst(rst),

                .read_index(pc_next_pred[SC_IDX_SIZE[i]+1:2] ^ folded_idx[i][SC_IDX_SIZE[i]-1:0]),

                .update_en(update_i),
                .taken_i(actual_taken_i),
                .update_read_index(pc_update_read[SC_IDX_SIZE[i]+1:2] ^ update_folded_idx[i][SC_IDX_SIZE[i]-1:0]),
                .update_write_index(pc_update_write[SC_IDX_SIZE[i]+1:2] ^ write_folded_idx[i][SC_IDX_SIZE[i]-1:0]),

                .ctr_out(ctr_tables[i])
            );
        end
    endgenerate

    // Calculate Contribution Weighted
    generate
        for (j = 0; j < SC_N_TABLES; j++) begin : weight_gen
            assign weighted_ctr_tables[j] = ($signed({{(SUM_WIDTH-SC_CTR_SIZE){ctr_tables[j][SC_CTR_SIZE-1]}}, ctr_tables[j]}) <<< 1) + 1;
        end
    endgenerate

    // Calculate SC tables sum
    always_comb begin
        sc_sum = '0;
        for (int i = 0; i < SC_N_TABLES; i++) begin
            sc_sum += $signed(weighted_ctr_tables[i]);
        end
    end

    assign sc_sum_o  = sc_sum;
    
endmodule