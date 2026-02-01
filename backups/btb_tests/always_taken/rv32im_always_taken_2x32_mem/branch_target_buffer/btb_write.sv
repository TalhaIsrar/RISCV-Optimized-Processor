module btb_write(
    input logic [127:0] update_set,
    input logic [31:0] LRU,
    input logic [24:0] update_tag,
    input logic [4:0] update_index,
    input logic [31:0] update_target,
    input logic mispredicted,
    output logic [127:0] write_set,
    output logic next_LRU_write
);
    // EX Stage operations
    wire current_LRU_write;

    // Extract Signals from Set
    wire [63:0] branch1, branch2;
    wire valid1, valid2;
    wire [24:0] tag1, tag2;
    wire [31:0] target1, target2;
    wire [1:0] state1, state2;

    // Final write singals to put into BTB
    wire write_valid1, write_valid2;
    wire [24:0] write_tag1, write_tag2;
    wire [31:0] write_target1, write_target2;

    // Check for each branch in set
    wire check_branch1, check_branch2;
    wire entry_exists;

    // Insert data branches
    wire insert_branch1, insert_branch2;

    // Branch to take
    wire take_branch1, take_branch2;

    wire [1:0] write_state1, write_state2;

    // Set (128 bits) = Branch1 (64 bits) + Branch2(64 bits)
    // Branch (64 bits) = Valid (1 bit) + Tag (27 bits) + Target (32 bits) + State (2 bits) + N/A (2 bits)
    assign branch1 = update_set[127:64];
    assign branch2 = update_set[63:0];

    assign valid1 = branch1[63];
    assign valid2 = branch2[63];

    assign tag1 = branch1[62:38];
    assign tag2 = branch2[62:38];

    assign target1 = branch1[37:6];
    assign target2 = branch2[37:6];

    // 2 Possible cases:
    // Tag exists and we only need to update
    // Tag doesnt exist and we need to add new entry in BTB File

    // Comparator + AND Gate to check if required tag exists in branch and if value is valid    assign check_branch1 = valid1 && (read_tag == tag1);
    assign check_branch1 = valid1 && (update_tag == tag1);    
    assign check_branch2 = valid2 && (update_tag == tag2);

    // Check if entry exist in either branches in a set
    // Entry exists = 1 else 0 if doesnt exists
    assign entry_exists = check_branch1 || check_branch2;

    // Read the LRU value for the current set
    assign current_LRU_write = LRU[update_index];

    // Path if tag doesnt exist
    // Use LRU to decide to write in Branch1 or branch0
    assign insert_branch1 = entry_exists ? check_branch1 : current_LRU_write;
    assign insert_branch2 = entry_exists ? check_branch2 : !current_LRU_write;

    // Valid remain 1 if it was 1 and if new value is being inserted
    assign write_valid1 = valid1 || insert_branch1;
    assign write_valid2 = valid2 || insert_branch2;

    // Mux to select which branch to replace tag of and which to keep as old one
    assign write_tag1 = insert_branch1 ? update_tag : tag1;
    assign write_tag2 = insert_branch2 ? update_tag : tag2;

    // Mux to select which branch to write new/updated target into and which to keep as old one
    assign write_target1 = insert_branch1 ? update_target : target1;
    assign write_target2 = insert_branch2 ? update_target : target2;

    assign write_state1 = 2'b10;
    assign write_state2 = 2'b10;  // Always Taken

    // Initialize the final set which we have to replace in BTB file
    // Set is formed from concationation of all results calculated above
    assign write_set = { write_valid1, write_tag1, write_target1, write_state1, 4'b0000,
                         write_valid2, write_tag2, write_target2, write_state2, 4'b0000};

    // Calculate the next LRU value for current set
    assign next_LRU_write = entry_exists ? current_LRU_write : insert_branch2;

endmodule