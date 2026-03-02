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
    output logic [2:0]           ctr_o,

    // Update (EX stage)
    input  logic                 update_i,      // update provider
    input  logic                 alloc_i,       // allocate new entry
    input  logic                 taken_i,       // actual outcome
    input  logic                 set_u_i,       // set usefulness=1
    input  logic                 clr_u_i,       // clear usefulness=0

    input  logic [TAGE_IDX_SIZE-1:0]      update_index_i,
    input  logic [TAGE_TAG_SIZE-1:0]      update_tag_i,
    input  logic [TAGE_IDX_SIZE-1:0]      write_index_i
);

    localparam ENTRIES = (1 << TAGE_IDX_SIZE);

    // Storage arrays
    (* ram_style = "block" *) logic [TAGE_TAG_SIZE-1:0] tag   [0:ENTRIES-1];
    (* ram_style = "block" *) logic [2:0] ctr [0:ENTRIES-1];
    (* ram_style = "block" *) logic [2:0] ctr2 [0:ENTRIES-1];
    (* ram_style = "block" *) logic       u   [0:ENTRIES-1];

    logic u_update, u_update_en;
    logic [2:0]pred_read, update_ctr, update_ctr_final;
    logic u_read;
    logic [TAGE_TAG_SIZE-1:0] tag_read,tag_delay,update_tag_delay;
    logic [2:0] ctr_update;
    logic  ctr_update_en;

    logic [TAGE_IDX_SIZE-1:0]      read_index_delay,write_index_delay,update_index_delay;
    logic tag_en_delay, u_en_delay, ctr_en_delay;
    logic [TAGE_TAG_SIZE-1:0] write_tag_delay;
    logic write_u_delay;
    logic [2:0] write_ctr_delay;

    logic [TAGE_TAG_SIZE-1:0] tag_final;
    logic [2:0] pred_final;
    logic u_final;

    // Initialization
    integer i;
    initial begin
        for (i = 0; i < ENTRIES; i++) begin
            tag[i] = '0;
            ctr[i] = 3'd3;
            ctr2[i] = 3'd3;
            u[i]   = 1'b0;
        end
    end

    always_ff  @(posedge clk) begin
        // Prediction read
        tag_read <= tag[index_i];
        pred_read <= ctr[index_i];
        u_read <= u[index_i];

        // Update ctr read
        update_ctr <= ctr2[update_index_i];
    end

    always_ff @(posedge clk) begin
        tag_delay <= tag_i;
        update_tag_delay <= update_tag_i;
    end

    // Combinational logic to calculate next ctr and u
    always_comb begin
        u_update = 1'b0;
        u_update_en = 1'b0;

        ctr_update_en = 1'b0;
        ctr_update    = update_ctr_final;  // default hold

        // Allocation case
        if (alloc_i) begin
            ctr_update_en = 1'b1;
            u_update_en   = 1'b1;
            u_update      = 1'b0;
            ctr_update = taken_i ? 3'd4 : 3'd3;
        end
        // Provider update case
        else if (update_i) begin
            if (taken_i) begin
                if (update_ctr_final != 3'd7) begin
                    ctr_update = update_ctr_final + 1;
                    ctr_update_en = 1'b1;
                end
            end else begin
                if (update_ctr_final != 3'd0) begin
                    ctr_update = update_ctr_final - 1;
                    ctr_update_en = 1'b1;
                end
            end

            if (set_u_i) begin
                u_update = 1'b1;
                u_update_en   = 1'b1;
            end
            if (clr_u_i) begin
                u_update = 1'b0;
                u_update_en   = 1'b1;
            end
        end
    end

    // Update logic (sequential)
    always_ff @(posedge clk) begin
        // Tag Allocation
        if (alloc_i)        tag[write_index_i] <= update_tag_delay;
        if (u_update_en)    u[write_index_i] <= u_update;
        if (ctr_update_en)  ctr[write_index_i] <= ctr_update;
        if (ctr_update_en)  ctr2[write_index_i] <= ctr_update;
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            read_index_delay <= 0;
            write_index_delay <= 0;
            update_index_delay <= 0;
            tag_en_delay <= 0;
            u_en_delay <= 0;
            ctr_en_delay <= 0;
            write_tag_delay <= 0;
            write_u_delay <= 0;
            write_ctr_delay <= 0;
        end else begin
            read_index_delay <= index_i;
            write_index_delay <= write_index_i;
            update_index_delay <= update_index_i;
            tag_en_delay <= alloc_i;
            u_en_delay <= u_update_en;
            ctr_en_delay <= ctr_update_en;
            write_tag_delay <= update_tag_delay;
            write_u_delay <= u_update;
            write_ctr_delay <= ctr_update;
        end
    end

    assign tag_final = (read_index_delay == write_index_delay) && tag_en_delay ? write_tag_delay : tag_read;
    assign pred_final = (read_index_delay == write_index_delay) && ctr_en_delay ? write_ctr_delay : pred_read;
    assign u_final = (read_index_delay == write_index_delay) && u_en_delay ? write_u_delay : u_read;
    assign update_ctr_final = (update_index_delay == write_index_delay) && ctr_en_delay ? write_ctr_delay : update_ctr;


    assign hit_o  = (tag_final == tag_delay);
    assign pred_o = (pred_final >= 3'd4);
    assign u_o    = u_final;
    assign ctr_o  = pred_final;


endmodule
