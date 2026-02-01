module pc_jump(
    input logic pred_valid,
    input logic [31:0] predicted_pc,
    input logic [31:0] pc,
    input logic signed [31:0] immediate,
    input logic [31:0] op1,
    input logic [2:0] func3,
    input logic [2:0] alu_flags,
    input logic predictedTaken,
    input logic [8:0] decoded_instruction,

    output logic [31:0] update_pc,
    output logic [31:0] btb_update_target,
    output logic modify_pc,
    output logic btb_update
);
    wire signed [31:0] input_a; 
    wire [31:0] adder_out;
    wire [31:0] pc_inc;
    wire lt_flag, ltu_flag, zero_flag;
    wire jalr_inst, jump_inst, branch_inst;
    wire branch_taken;

    assign lt_flag = alu_flags[2];
    assign ltu_flag = alu_flags[1];
    assign zero_flag = alu_flags[0];

    // decoded_instruction = {r_type_inst, i_type_inst, s_type_inst, wb_load, u_type_inst, b_type_inst, j_type_inst, aupic_inst, jalr_inst};
    assign jalr_inst = decoded_instruction[0];
    assign jump_inst = decoded_instruction[2] || jalr_inst;
    assign branch_inst = decoded_instruction[3];

    // Compute branch/jump enable
    wire beq  = (func3 == 3'b000);
    wire bne  = (func3 == 3'b001);
    wire blt  = (func3 == 3'b100);
    wire bge  = (func3 == 3'b101);
    wire bltu = (func3 == 3'b110);
    wire bgeu = (func3 == 3'b111);

    assign input_a = jalr_inst ? op1 : pc;
    assign adder_out = $signed(input_a) + $signed(immediate);
    assign btb_update_target = jalr_inst ? (adder_out & 32'hFFFFFFFE) : adder_out;
    assign pc_inc = pc + 32'h4;

    assign branch_taken = (beq  &&  zero_flag) ||
                        (bne  && ~zero_flag) ||
                        (blt  &&  lt_flag)   ||
                        (bge  && ~lt_flag)   ||
                        (bltu &&  ltu_flag)  ||
                        (bgeu && ~ltu_flag) ;


    wire branch_mispredicted = branch_inst && ((branch_taken ^ predictedTaken) || (btb_update_target != predicted_pc));
    wire jump_mispredicted = jump_inst && (!predictedTaken || (btb_update_target != predicted_pc));

    assign btb_update = jump_inst || branch_inst;
    assign modify_pc = !pred_valid ? (jump_inst || (branch_taken && branch_inst)) : (branch_mispredicted || jump_mispredicted);
    assign update_pc = !pred_valid || jump_inst || branch_taken ? btb_update_target : pc_inc;


endmodule