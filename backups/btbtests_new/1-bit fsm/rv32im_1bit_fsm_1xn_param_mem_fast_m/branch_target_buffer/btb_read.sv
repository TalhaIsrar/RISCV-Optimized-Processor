module btb_read #(parameter N = 32)(
    input logic [63:0] read_set,
    input logic [29-$clog2(N):0] read_tag,  // 26:0,  25:0,  24:0
    input logic [$clog2(N)-1:0] read_index, // 3-1:0, 4-1:0, 5-1:0
    output logic valid,
    output logic predictedTaken,
    output logic [31:0] target
);

    // Extract Signals from Set
    wire read_valid;
    wire [29-$clog2(N):0] tag;
    wire state;

    // Set (128 bits) = Branch1 (64 bits) + Branch2(64 bits)
    // Branch (64 bits) = Valid (1 bit) + Tag (27 bits) + Target (32 bits) + State (2 bits) + N/A (2 bits)
    assign read_valid = read_set[63];

    assign tag = read_set[62:33+$clog2(N)];                 // Tag:    62:36, 62:37, 62:38
                                                            // Index:  3-1:0, 4-1:0, 5-1:0
    assign target = read_set[32+$clog2(N):1+$clog2(N)];     // Target: 35:4,  36:5,  37:6

    assign state = read_set[$clog2(N)];

    // Valid Signal checks if any branch has tag
    assign valid = read_valid && (read_tag == tag);

    // predictedTaken is 0 for strongNotTaken(00) && weakNotTaken(01)
    // predictedTaken is 1 for strongTaken(10) && weakTaken(11)
    // This is same as MSB of state
    assign predictedTaken = state;

endmodule