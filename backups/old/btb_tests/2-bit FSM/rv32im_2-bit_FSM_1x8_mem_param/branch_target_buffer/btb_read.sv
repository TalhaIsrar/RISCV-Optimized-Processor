module btb_read #(parameter M = 128, parameter N = 32)(
    input logic [M-1:0] read_set,
    input logic [29-$clog2(N):0] read_tag,
    input logic [$clog2(N)-1:0] read_index,
    output logic valid,
    output logic predictedTaken,
    output logic [31:0] target
);
    // Extract Signals from Set
    wire read_valid;
    wire [29-$clog2(N):0] tag;
    wire [1:0] state;

    // Current state of read PC in Dynamic 2 bit predictor
    wire [1:0] current_state;

    // Set (128 bits) = Branch1 (64 bits) + Branch2(64 bits)
    // Branch (64 bits) = Valid (1 bit) + Tag (27 bits) + Target (32 bits) + State (2 bits) + N/A (2 bits)
    assign read_valid = read_set[63];

    assign tag = read_set[62:33+$clog2(N)];

    assign target = read_set[32+$clog2(N):1+$clog2(N)];

    assign state = read_set[$clog2(N):$clog2(N)-1];
    
    // Check branches
    assign valid = read_valid && (read_tag == tag);

    // Extract the state of the read PC
    assign current_state = state;

    // predictedTaken is 0 for strongNotTaken(00) && weakNotTaken(01)
    // predictedTaken is 1 for strongTaken(10) && weakTaken(11)
    // This is same as MSB of state
    assign predictedTaken = current_state[1];

endmodule