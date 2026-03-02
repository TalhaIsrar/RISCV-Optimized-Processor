module bpu_top #(
    parameter N_TABLES = 7,
    parameter GHR_SIZE = 256,
    parameter BTB_SIZE = 2048,
    parameter BIMODAL_IDX = 11,
    parameter int TAGE_HIST_LEN [N_TABLES] = '{10, 20, 30, 40, 50, 60, 70},
    parameter int TAGE_IDX_SIZE [N_TABLES] = '{9, 9, 9, 9, 9, 9, 9},
    parameter int TAGE_TAG_SIZE [N_TABLES] = '{9, 9, 9, 9, 9, 9, 9}
)(

    input  logic         clk,
    input  logic         rst,

    // IF stage
    input  logic [31:0]  if_pc,
    input  logic [31:0]  next_if_pc, // for sequential fetch

    // EX stage updates
    input  logic         update_i,        // enable update
    input  logic [31:0]  ex_update_pc,   // PC of branch to update
    input  logic [31:0]  mem_update_pc,   // PC of branch to update
    input  logic [31:0]  update_target,   // target PC
    input  logic         update_taken,    // actual branch outcome
    input  logic         update_uncond_inst, // update BTB unconditional flag
    input  logic         misprediction,

    input logic [N_TABLES-1:0] tag_hits_in,
    input logic [N_TABLES-1:0] u_bits_in,
    input logic [$clog2(N_TABLES)-1:0] provider_table_in,
    input logic [$clog2(N_TABLES)-1:0] alloc_table_in,
    input logic [GHR_SIZE-1:0] ghr_ex,
    input logic [GHR_SIZE-1:0] ghr_mem,

    // Outputs
    output logic [31:0]  target_pc,
    output logic         target_valid,
    output logic         pred_taken,        // TAGE prediction

    output logic [N_TABLES-1:0] tag_hits_out,
    output logic [N_TABLES-1:0] u_bits_out,
    output logic [$clog2(N_TABLES)-1:0] provider_table_out,
    output logic [$clog2(N_TABLES)-1:0] alloc_table_out,
    output logic [GHR_SIZE-1:0] ghr_out 

);
    logic update_en_branch;
    logic tage_pred;

    logic [31:0] btb_target;
    logic btb_valid;
    logic btb_uncond;
    logic btb_write_en;
    
    localparam WEIGHT_WIDTH = SC_CTR_SIZE + 1;
    localparam SUM_WIDTH = SC_CTR_SIZE + 4;

    logic signed [SUM_WIDTH-1:0] sc_sum, sc_sum_abs;
    logic [31:0] sc_sum_abs32;
    logic signed [7:0] tageCtrCentered;
    logic signed [SUM_WIDTH:0] totalSum, totalSumAbs ;
    logic pred_o;

    logic [4:0] sc_bank_ctr;        // counter controlling threshold
    logic [4:0] next_ctr;
    logic provider_exists;
    logic signed [SUM_WIDTH:0] sc_bank_thres;

    logic sc_flipped;
    logic tage_weak;

    assign provider_exists = |tag_hits_out;
    assign update_en_branch = update_i && !update_uncond_inst;

    // TAGE Predictor
    tage_top #(
        .GHR_SIZE(GHR_SIZE),
        .N_TABLES(N_TABLES),
        .BIMODAL_IDX(BIMODAL_IDX),
        .TAGE_HIST_LEN(TAGE_HIST_LEN),
        .TAGE_IDX_SIZE(TAGE_IDX_SIZE),
        .TAGE_TAG_SIZE(TAGE_TAG_SIZE)
    ) tage_inst (
        .clk(clk),
        .rst(rst),
        .pc_next_pred_i(next_if_pc),
        .pc_pred_i(if_pc),
        .pc_ex(ex_update_pc),
        .pc_upd_i(mem_update_pc),
        .br_resolved_i(update_en_branch),
        .br_taken_i(update_taken),
        .update_i(update_en_branch),
        .ghr_out(ghr_out),
        .pred_o(tage_pred),
        .tag_hits(tag_hits_out),
        .u_bits(u_bits_out),
        .provider_table(provider_table_out),
        .alloc_table(alloc_table_out),

        .ghr_ex(ghr_ex),
        .ghr_mem(ghr_mem),
        .tag_hits_in(tag_hits_in),
        .u_bits_in(u_bits_in),
        .provider_table_in(provider_table_in),
        .alloc_table_in(alloc_table_in),
        .tageCtrCentered(tageCtrCentered)
    );

    // GHR
    ghr #(.GHR_SIZE(GHR_SIZE)) gh (
        .clk(clk),
        .rst(rst),
        .update_i(update_en_branch),
        .taken_i(update_taken),
        .history_o(ghr_out)
    );

    // BTB
    assign btb_write_en = update_i && update_taken;

    btb #(.BTB_SIZE(BTB_SIZE)) btb_inst (
        .clk(clk),
        .rst(rst),
        .next_if_pc(next_if_pc),
        .if_pc(if_pc),
        .mem_update_pc(mem_update_pc),
        .update_target(update_target),
        .update_en(btb_write_en),
        .update_uncond_inst(update_uncond_inst),
        .target_pc(btb_target),
        .btb_hit(btb_valid),
        .target_uncond_inst(btb_uncond)
    );

    // Combine TAGE + BTB
    always_comb begin
        target_pc = btb_target;
        target_valid = btb_valid;
        pred_taken = tage_pred || btb_uncond;
    end

endmodule
