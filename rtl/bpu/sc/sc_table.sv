module sc_table #(
    parameter SC_IDX_SIZE = 9,
    parameter SC_CTR_SIZE = 6
)(
    input  logic                 clk,
    input  logic                 rst,

    // Prediction (IF stage)
    input  logic [SC_IDX_SIZE-1:0] read_index,

    // Update
    input  logic update_en,
    input  logic taken_i,
    input  logic [SC_IDX_SIZE-1:0] update_read_index,
    input  logic [SC_IDX_SIZE-1:0] update_write_index,

    output logic signed [5:0] ctr_out
);

    localparam ENTRIES = (1 << SC_IDX_SIZE);
    localparam signed [SC_CTR_SIZE-1:0] MAX_VAL =  (1 <<< (SC_CTR_SIZE-1)) - 1;
    localparam signed [SC_CTR_SIZE-1:0] MIN_VAL = -(1 <<< (SC_CTR_SIZE-1));

    (* ram_style = "block" *) logic signed [SC_CTR_SIZE-1:0] ctr1 [0:ENTRIES-1];
    (* ram_style = "block" *) logic signed [SC_CTR_SIZE-1:0] ctr2 [0:ENTRIES-1];

    logic signed [SC_CTR_SIZE-1:0] read_ctr, update_ctr, update_ctr_next, update_ctr_final;
    logic ctr_update_en;

    // Delay signals
    logic [SC_IDX_SIZE-1:0] read_index_delay, update_read_index_delay, update_write_index_delay;
    logic ctr_update_en_delay;
    logic signed [SC_CTR_SIZE-1:0] update_ctr_next_delay;

    // Initialization
    integer i;
    initial begin
        for (i = 0; i < ENTRIES; i++) begin
            ctr1[i] = 0;
            ctr2[i] = 0;
        end
    end

    always_ff  @(posedge clk) begin
        // Prediction ctr read
        read_ctr <= ctr1[read_index];

        // Update ctr read
        update_ctr <= ctr2[update_read_index];
    end

    // Next counter logic
    always_comb begin
        ctr_update_en = 0;
        update_ctr_next = update_ctr_final;

        if (update_en) begin
            if (taken_i) begin
                if (update_ctr_final != MAX_VAL) begin
                    update_ctr_next = update_ctr_final + 1;
                    ctr_update_en = 1;
                end
            end else begin
                if (update_ctr_final != MIN_VAL) begin
                    update_ctr_next = update_ctr_final - 1;
                    ctr_update_en = 1;
                end
            end
        end

    end
    
    // Write Counter
    always_ff @(posedge clk) begin
        if (ctr_update_en)  ctr1[update_write_index] <= update_ctr_next;
        if (ctr_update_en)  ctr2[update_write_index] <= update_ctr_next;
    end

    // Delay logic in case of read/write same index
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            read_index_delay <= 0;
            update_read_index_delay <= 0;
            update_write_index_delay <= 0;
            ctr_update_en_delay <= 0;
            update_ctr_next_delay <= 0;
        end else begin
            read_index_delay <= read_index;
            update_read_index_delay <= update_read_index;
            update_write_index_delay <= update_write_index;
            ctr_update_en_delay <= ctr_update_en;
            update_ctr_next_delay <= update_ctr_next;
        end
    end 

    assign ctr_out = (read_index_delay == update_write_index_delay) && ctr_update_en_delay ? update_ctr_next_delay : read_ctr;
    assign update_ctr_final = (update_read_index_delay == update_write_index_delay) && ctr_update_en_delay ? update_ctr_next_delay : update_ctr;

endmodule