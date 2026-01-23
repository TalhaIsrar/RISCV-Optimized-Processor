module pc_jump(
    input pred_valid,
    input [31:0] predicted_pc,
    input [31:0] pc,
    input signed [31:0] immediate,
    input [31:0] op1,
    input [6:0] opcode,
    input [2:0] func3,
    input lt_flag,
    input ltu_flag,
    input zero_flag,
    input predictedTaken,
    output [31:0] update_pc,
    output [31:0] jump_addr,
    output modify_pc,
    output update_btb
);
    wire signed [31:0] input_a; 
    wire jump_inst, branch_inst;
    wire jalr_inst;
    wire branch_taken;
    wire jump_en;
    wire [31:0] adder_out;
    wire [31:0] pc_inc;

    assign jalr_inst = opcode ==7'b1100111;
    assign jump_inst = (opcode ==7'b1101111) || jalr_inst;
    assign branch_inst = (opcode == 7'b1100011);

    // Compute branch/jump enable
    wire beq  = (func3 == 3'b000);
    wire bne  = (func3 == 3'b001);
    wire blt  = (func3 == 3'b100);
    wire bge  = (func3 == 3'b101);
    wire bltu = (func3 == 3'b110);
    wire bgeu = (func3 == 3'b111);

    assign input_a = jalr_inst ? op1 : pc;
    assign adder_out = $signed(input_a) + $signed(immediate);
    assign jump_addr = jalr_inst ? (adder_out & 32'hFFFFFFFE) : adder_out;
    assign pc_inc = pc + 32'h4;

    assign branch_taken = (beq  &&  zero_flag) ||
                        (bne  && ~zero_flag) ||
                        (blt  &&  lt_flag)   ||
                        (bge  && ~lt_flag)   ||
                        (bltu &&  ltu_flag)  ||
                        (bgeu && ~ltu_flag) ;


    wire branch_mispredicted = branch_inst && ((branch_taken ^ predictedTaken) || (jump_addr != predicted_pc));
    wire jump_mispredicted = jump_inst && (!predictedTaken || (jump_addr != predicted_pc));

    assign update_btb = jump_inst || branch_inst;
    assign modify_pc = !pred_valid ? (jump_inst || (branch_taken && branch_inst)) : (branch_mispredicted || jump_mispredicted);
    assign update_pc = !pred_valid ? jump_addr : (jump_inst ? jump_addr : (branch_taken ? jump_addr : pc_inc));


endmodule