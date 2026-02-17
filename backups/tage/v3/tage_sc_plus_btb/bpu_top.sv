module bpu_top #(
    parameter N_TABLES = 2,
    parameter GHR_SIZE = 128,
    parameter BTB_SIZE = 1024
)(
    input  logic         clk,
    input  logic         rst,

    // IF stage
    input  logic [31:0]  if_pc,
    input  logic [31:0]  next_if_pc, // for sequential fetch

    // GHR update
    input  logic         id_is_branch,
    input  logic         id_is_taken,
    input  logic         id_pred_valid,

    // EX stage updates
    input  logic         update_i,        // enable update
    input  logic [31:0]  mem_update_pc,   // PC of branch to update
    input  logic [31:0]  update_target,   // target PC
    input  logic         update_taken,    // actual branch outcome
    input  logic         update_uncond_inst, // update BTB unconditional flag
    input  logic         misprediction,

    // Outputs
    output logic [31:0]  target_pc,
    output logic         target_valid,
    output logic         pred_taken        // TAGE prediction
);
    logic [GHR_SIZE-1:0] ghr_out;

    logic update_en_branch;
    assign update_en_branch = update_i && !update_uncond_inst;

    // TAGE Predictor
    logic tage_pred;
    tage_top #(
        .GHR_SIZE(GHR_SIZE),
        .N_TABLES(N_TABLES)
    ) tage_inst (
        .clk(clk),
        .rst(rst),
        .pc_pred_i(if_pc),
        .pc_upd_i(mem_update_pc),
        .br_resolved_i(update_en_branch),
        .br_taken_i(update_taken),
        .update_i(update_en_branch),
        .ghr_out(ghr_out),
        .pred_o(tage_pred)
    );

    // GHR
    ghr #(.GHR_SIZE(GHR_SIZE)) gh (
        .clk(clk),
        .rst(rst),
        .update_if(id_is_branch),
        .taken_if(id_is_taken && id_pred_valid),
        .update_final(update_en_branch),
        .taken_final(update_taken),
        .mis_prediction(misprediction),
        .history_o(ghr_out)
    );

    // BTB
    logic [31:0] btb_target;
    logic btb_valid;
    logic btb_uncond;
    logic btb_write_en;

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
