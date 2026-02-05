module btb_read #(parameter N = 32)(
    input logic clk,
    input logic rst,
    input logic [127:0] read_set,
    input logic [N-1:0] LRU,
    input logic [29-$clog2(N):0] read_tag,  // 26:0,  25:0,  24:0
    input logic [$clog2(N)-1:0] read_index, // 3-1:0, 4-1:0, 5-1:0
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
    wire [29-$clog2(N):0] tag1, tag2;
    wire [31:0] target1, target2;
    wire [1:0] state1, state2;

    // Check for each branch in set
    wire check_branch1, check_branch2;

    logic alternating_branch;

    // Set (128 bits) = Branch1 (64 bits) + Branch2(64 bits)
    // Branch (64 bits) = Valid (1 bit) + Tag (27 bits) + Target (32 bits) + State (2 bits) + N/A (2 bits)
    assign branch1 = read_set[127:64];
    assign branch2 = read_set[63:0];

    assign valid1 = branch1[63];
    assign valid2 = branch2[63];

    assign tag1 = branch1[62:33+$clog2(N)];     
    assign tag2 = branch2[62:33+$clog2(N)];                 // Tag:    62:36, 62:37, 62:38
                                                            // Index:  3-1:0, 4-1:0, 5-1:0
    assign target1 = branch1[32+$clog2(N):1+$clog2(N)];     // Target: 35:4,  36:5,  37:6
    assign target2 = branch2[32+$clog2(N):1+$clog2(N)];

    // Check branches
    assign check_branch1 = valid1 && (read_tag == tag1);
    assign check_branch2 = valid2 && (read_tag == tag2);

    // Valid Signal checks if any branch has tag
    assign valid = check_branch1 || check_branch2;

    // Target signals extracts value from correct branch
    assign target = check_branch1 ? target1 : target2;

     always_ff @(posedge clk, posedge rst) begin
        if (rst)
            alternating_branch <= '1;
        else
            alternating_branch <= ~alternating_branch;
    end

    assign predictedTaken = alternating_branch;

    // Calculate the next LRU value for current set
    assign current_LRU_read = LRU[read_index];
    assign next_LRU_read = check_branch2;
    
endmodule