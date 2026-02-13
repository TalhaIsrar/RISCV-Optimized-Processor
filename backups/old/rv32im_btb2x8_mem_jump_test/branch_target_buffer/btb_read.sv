module btb_read(
    input logic [127:0] read_set,
    input logic [7:0] LRU,
    input logic [26:0] read_tag,
    input logic [2:0] read_index,
    output logic next_LRU_read,
    output logic valid,
    output logic predictedTaken,
    output logic [31:0] target
);
    // IF Stage Operations
    wire current_LRU_read;

    // Extract Signals from Set
    wire [63:0] branch1, branch2;
    wire valid1, valid2;
    wire [26:0] tag1, tag2;
    wire [31:0] target1, target2;
    wire [1:0] state1, state2;

    // Check for each branch in set
    wire check_branch1, check_branch2;

    // Current state of read PC in Dynamic 2 bit predictor
    wire [1:0] current_state;

    // Set (128 bits) = Branch1 (64 bits) + Branch2(64 bits)
    // Branch (64 bits) = Valid (1 bit) + Tag (27 bits) + Target (32 bits) + State (2 bits) + N/A (2 bits)
    assign branch1 = read_set[127:64];
    assign branch2 = read_set[63:0];

    assign valid1 = branch1[63];
    assign valid2 = branch2[63];

    assign tag1 = branch1[62:36];
    assign tag2 = branch2[62:36];

    assign target1 = branch1[35:4];
    assign target2 = branch2[35:4];

    assign state1 = branch1[3:2];
    assign state2 = branch2[3:2];

    // Check branches
    assign check_branch1 = valid1 && (read_tag == tag1);
    assign check_branch2 = valid2 && (read_tag == tag2);

    // Valid Signal checks if any branch has tag
    assign valid = check_branch1 || check_branch2;

    // Target signals extracts value from correct branch
    assign target = check_branch1 ? target1 : target2;

    // Extract the state of the read PC
    assign current_state = check_branch1 ? state1 : (
                           check_branch2 ? state2 : 2'b00);

    // predictedTaken is 0 for strongNotTaken(00) && weakNotTaken(01)
    // predictedTaken is 1 for strongTaken(10) && weakTaken(11)
    // This is same as MSB of state
    assign predictedTaken = current_state[1];

    // Calculate the next LRU value for current set
    assign current_LRU_read = LRU[read_index];
    assign next_LRU_read = valid ? check_branch2 : current_LRU_read;
    
endmodule