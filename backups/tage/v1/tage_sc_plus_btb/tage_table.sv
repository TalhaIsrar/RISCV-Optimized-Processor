module tage_table #(
    parameter IDXW = 8,        // index width (256 entries default)
    parameter TAGW = 8         // tag width
)(
    input  logic                 clk,
    input  logic                 rst,

    // ========= Prediction (IF stage) =========
    input  logic [IDXW-1:0]      index_i,
    input  logic [TAGW-1:0]      tag_i,

    output logic                 hit_o,
    output logic                 pred_o,
    output logic                 u_o,

    // ========= Update (EX stage) =========
    input  logic                 update_i,      // update provider
    input  logic                 alloc_i,       // allocate new entry
    input  logic                 taken_i,       // actual outcome
    input  logic                 set_u_i,       // set usefulness=1
    input  logic                 clr_u_i,       // clear usefulness=0

    input  logic [IDXW-1:0]      update_index_i,
    input  logic [TAGW-1:0]      update_tag_i
);

    localparam ENTRIES = (1 << IDXW);

    // ----------------------------
    // Storage arrays
    // ----------------------------
    logic [TAGW-1:0] tag   [ENTRIES-1:0];
    logic signed [2:0] ctr [ENTRIES-1:0];   // signed counter
    logic              u   [ENTRIES-1:0];

    // ----------------------------
    // Reset / Initialization
    // ----------------------------
    integer i;
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < ENTRIES; i++) begin
                tag[i] <= '0;
                ctr[i] <= 3'b111;   // weak NOT TAKEN (-1)
                u[i]   <= 1'b0;
            end
        end
    end

    // ----------------------------
    // Prediction read (combinational)
    // ----------------------------
    logic [TAGW-1:0] tag_r;
    logic signed [2:0] ctr_r;
    logic u_r;

    assign tag_r = tag[index_i];
    assign ctr_r = ctr[index_i];
    assign u_r   = u[index_i];

    assign hit_o  = (tag_r == tag_i);
    assign pred_o = (ctr_r >= 0);   // >=0 means TAKEN
    assign u_o    = u_r;

    // ----------------------------
    // Update logic (sequential)
    // ----------------------------
    always_ff @(posedge clk) begin

        // -------- Allocation --------
        if (alloc_i) begin
            tag[update_index_i] <= update_tag_i;
            ctr[update_index_i] <= taken_i ? 3'sd1 : -3'sd1; // weak correct
            u[update_index_i]   <= 1'b0;
        end

        // -------- Provider Update --------
        else if (update_i) begin

            // Update counter (saturating)
            if (taken_i) begin
                if (ctr[update_index_i] != 3'sd3)
                    ctr[update_index_i] <= ctr[update_index_i] + 1;
            end
            else begin
                if (ctr[update_index_i] != -3'sd4)
                    ctr[update_index_i] <= ctr[update_index_i] - 1;
            end

            // Update usefulness
            if (set_u_i)
                u[update_index_i] <= 1'b1;
            if (clr_u_i)
                u[update_index_i] <= 1'b0;
        end
    end

endmodule
