module sc_table #(
    parameter SC_IDX_SIZE = 9,
)(
    input  logic                 clk,
    input  logic                 rst,

);

    localparam ENTRIES = (1 << TAGE_IDX_SIZE);

    logic signed [2:0] ctr1 [ENTRIES-1:0];
    logic [2:0] ctr2 [ENTRIES-1:0];


endmodule
