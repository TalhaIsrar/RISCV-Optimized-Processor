module tage_table #(
    parameter TAGE_IDX_SIZE = 8,        // index width (256 entries default)
    parameter TAGE_TAG_SIZE = 8         // tag width
)(
    input  logic                 clk,
    input  logic                 rst,

    // Prediction (IF stage)
    input  logic [TAGE_IDX_SIZE-1:0]      index_i,
    input  logic [TAGE_TAG_SIZE-1:0]      tag_i,

    output logic                 hit_o,
    output logic                 pred_o,
    output logic                 u_o,

    // Update (EX stage)
    input  logic                 update_i,      // update provider
    input  logic                 alloc_i,       // allocate new entry
    input  logic                 taken_i,       // actual outcome
    input  logic                 set_u_i,       // set usefulness=1
    input  logic                 clr_u_i,       // clear usefulness=0

    input  logic [TAGE_IDX_SIZE-1:0]      update_index_i,
    input  logic [TAGE_TAG_SIZE-1:0]      update_tag_i
);

    localparam ENTRIES = (1 << TAGE_IDX_SIZE);

    // Storage arrays
    logic [TAGE_TAG_SIZE-1:0] tag   [ENTRIES-1:0];
    logic signed [2:0] ctr [ENTRIES-1:0];   // signed counter
    logic              u   [ENTRIES-1:0];

    // Reset / Initialization
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

    // Prediction read (combinational)
    assign hit_o  = (tag[index_i] == tag_i);
    assign pred_o = (ctr[index_i] >= 0);
    assign u_o    = u[index_i];

    // Update logic (sequential)
    always_ff @(posedge clk) begin

        // Allocation
        if (alloc_i) begin
            tag[update_index_i] <= update_tag_i;
            ctr[update_index_i] <= taken_i ? 3'sd1 : -3'sd1; // weak correct
            u[update_index_i]   <= 1'b0;
        end

        // Provider Update
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
