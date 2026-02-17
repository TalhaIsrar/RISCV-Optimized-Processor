module bpu_top #(
    parameter N_TABLES = 2,
    parameter HIST_LEN = 1024
)(
    input  logic         clk,
    input  logic         rst,

    // IF stage
    input  logic [31:0]  if_pc,
    input  logic [31:0]  next_if_pc, // for sequential fetch

    // EX stage updates
    input  logic         update_i,        // enable update
    input  logic [31:0]  mem_update_pc,   // PC of branch to update
    input  logic [31:0]  update_target,   // target PC
    input  logic         update_taken,    // actual branch outcome
    input  logic         update_uncond_inst, // update BTB unconditional flag

    // Outputs
    output logic [31:0]  target_pc,
    output logic         target_valid,
    output logic         pred_taken        // TAGE prediction
);

    // ----------------------------
    // 1. TAGE Predictor
    // ----------------------------
    logic tage_pred;
    tage_top #(
        .HIST_LEN(HIST_LEN),
        .N_TABLES(N_TABLES)
    ) tage_inst (
        .clk(clk),
        .rst(rst),
        .pc_pred_i(if_pc),
        .pc_upd_i(mem_update_pc),
        .br_resolved_i(update_i && !update_uncond_inst),
        .br_taken_i(update_taken),
        .update_i(update_i && !update_uncond_inst),
        .pred_o(tage_pred)
    );

    // ----------------------------
    // 2. BTB
    // ----------------------------
    logic [31:0] btb_target;
    logic btb_valid;
    logic btb_uncond;

    btb #(.N(1024)) btb_inst (
        .clk(clk),
        .rst(rst),
        .next_if_pc(next_if_pc),
        .if_pc(if_pc),
        .mem_update_pc(mem_update_pc),
        .update_target(update_target),
        .update_en(update_i&&update_taken),
        .update_uncond_inst(update_uncond_inst),
        .target_pc(btb_target),
        .target_valid(btb_valid),
        .target_uncond_inst(btb_uncond)
    );

    // ----------------------------
    // 3. Combine TAGE + BTB
    // ----------------------------
    always_comb begin
        target_pc = btb_target;
        target_valid = btb_valid;
        pred_taken = tage_pred || btb_uncond;
    end

endmodule
