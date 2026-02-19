module btb_file #(parameter BTB_SIZE = 32)(
    input logic clk,
    input logic rst,

    input logic [$clog2(BTB_SIZE)-1:0] read_index,
    input logic [$clog2(BTB_SIZE)-1:0] write_index,
    input logic write_en,

    input logic [63-$clog2(BTB_SIZE) : 0] write_data, // TAG(32-index) + target(32) + valid(1) + uncond_inst(1)
    output logic [63-$clog2(BTB_SIZE) : 0] read_data 
);

    (* ram_style = "block" *) logic [63-$clog2(BTB_SIZE):0] file [0:BTB_SIZE-1];
    logic [63-$clog2(BTB_SIZE) : 0] read_data_reg;

    logic [$clog2(BTB_SIZE)-1:0] read_index_delay;
    logic [$clog2(BTB_SIZE)-1:0] write_index_delay;
    logic write_en_delay;
    logic [63-$clog2(BTB_SIZE) : 0] write_data_delay; 

    // Not practical way but here we keep
    integer i;
    initial begin
        for (i = 0; i < BTB_SIZE; i = i + 1)
            file[i] = '0;
    end

    always_ff @(posedge clk) begin
        if (write_en) begin
            file[write_index] <= write_data;
        end
    end

    always_ff @(posedge clk) begin
        read_data_reg <= file[read_index];
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            read_index_delay <= 0;
            write_index_delay <= 0;
            write_en_delay <= 0;
            write_data_delay <= 0;
        end else begin
            read_index_delay <= read_index;
            write_index_delay <= write_index;
            write_en_delay <= write_en;
            write_data_delay <= write_data;
        end
    end

    assign read_data = ((read_index_delay == write_index_delay) && write_en_delay) ? write_data_delay : read_data_reg;

endmodule