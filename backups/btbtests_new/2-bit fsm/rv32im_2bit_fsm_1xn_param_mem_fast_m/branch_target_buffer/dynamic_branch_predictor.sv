module dynamic_branch_predictor(
    input logic [1:0] current_state,
    input logic mispredicted,
    output logic [1:0] next_state
);

    // FSM implementation based on case select logic
    // current state + mispredicted -> next_state
    always_comb begin
        case (current_state)
            2'b00: next_state = mispredicted ? 2'b01  : 2'b00;
            2'b01:   next_state = mispredicted ? 2'b10   : 2'b00;
            2'b10:     next_state = mispredicted ? 2'b11      : 2'b10;
            2'b11:       next_state = mispredicted ? 2'b00: 2'b10;
            default:           next_state = current_state;
        endcase
    end

endmodule
