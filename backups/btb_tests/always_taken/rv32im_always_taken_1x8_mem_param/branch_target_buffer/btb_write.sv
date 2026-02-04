module btb_write #(parameter M = 128, parameter N = 32)(
    input logic [M-1:0] update_set,
    input logic [29-$clog2(N):0] update_tag,
    input logic [$clog2(N)-1:0] update_index,
    input logic [31:0] update_target,
    input logic mispredicted,
    output logic [M-1:0] write_set
);
    // Extract Signals from Set
    wire valid;
    wire [29-$clog2(N):0] tag;
    wire [31:0] target;
    wire [1:0] state;

    // Final write singals to put into BTB
    wire write_valid;
    wire [29-$clog2(N):0] write_tag;
    wire [31:0] write_target;

    // Check for each branch in set
    wire entry_exists;

    wire [1:0] write_state;

    // Set (128 bits) = Branch1 (64 bits) + Branch2(64 bits)
    // Branch (64 bits) = Valid (1 bit) + Tag (27 bits) + Target (32 bits) + State (2 bits) + N/A (2 bits)
    assign valid = update_set[63];

    assign tag = update_set[62:33+$clog2(N)];               // 62:36, 62:37, 62:38
                                                    //Index: 3-1:0, 4-1:0, 5-1:0
    assign target = update_set[32+$clog2(N):1+$clog2(N)];   // 35:4,  36:5,  37:6

    // 2 Possible cases:
    // Tag exists and we only need to update
    // Tag doesnt exist and we need to add new entry in BTB File  

    // Valid remain 1 if it was 1 and if new value is being inserted
    assign write_valid = 1'b1;

    // Mux to select which branch to replace tag of and which to keep as old one
    assign write_tag = update_tag;

    // Mux to select which branch to write new/updated target into and which to keep as old one
    assign write_target = update_target;

    assign write_state = 2'b10; // Always Taken

    // Initialize the final set which we have to replace in BTB file
    // Set is formed from concationation of all results calculated above
    assign write_set = {write_valid, write_tag, write_target, write_state, {($clog2(N)-1){1'b0}}};
endmodule