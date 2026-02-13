module dynamic_branch_predictor(
    input logic current_state,
    input logic mispredicted,
    output logic next_state
);

    // FSM implementation based on case select logic
    // current state + mispredicted -> next_state
    always_comb begin
        case (current_state)
            1'b0: next_state = 1'b1;
            1'b1: next_state = 1'b0;
            default: next_state = current_state;
        endcase
    end

endmodule
