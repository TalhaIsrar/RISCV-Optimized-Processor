module execute_stage(
    input [31:0] predicted_pc,
    input [31:0] pc,
    input [31:0] op1,
    input [31:0] op2,
    input pipeline_flush,
    input [31:0] immediate,
    input [6:0] func7,
    input [2:0] func3,
    input [6:0] opcode,
    input ex_alu_src,
    input predictedTaken,
    input ex_wb_reg_file,
    input [4:0] alu_rd,
    input pred_valid,
    
    input [1:0] operand_a_forward_cntl,
    input [1:0] operand_b_forward_cntl,
    input [31:0] data_forward_mem,
    input [31:0] data_forward_wb,

    output wire [31:0] result,
    output wire [31:0] op1_selected,
    output wire [31:0] op2_selected,
    output wire [31:0] pc_jump_addr,
    output wire jump_en,
    output wire update_btb,
    output wire [31:0] calc_jump_addr,
    output wire [4:0] wb_rd,
    output wire wb_reg_file
);

    wire [3:0] ALUControl;
    reg [31:0] op1_forwarded;
    reg [31:0] op2_forwarded;
    reg [31:0] op1_alu;
    reg [31:0] op2_alu;
    wire [31:0] alu_result;

    wire [31:0] op1_valid;
    wire [31:0] op2_valid;

    wire lt_flag;
    wire ltu_flag;
    wire zero_flag;    

    // Mux for forwarding operand 1
    always @(*) begin
        case (operand_a_forward_cntl)
            2'b01: op1_forwarded = data_forward_mem;
            2'b10:  op1_forwarded = data_forward_wb;
            default:      op1_forwarded = op1;
        endcase
    end

    // Mux for forwarding operand 2
    always @(*) begin
        case (operand_b_forward_cntl)
            2'b01: op2_forwarded = data_forward_mem;
            2'b10:  op2_forwarded = data_forward_wb;
            default:      op2_forwarded = op2;
        endcase
    end

    // Pass op2 directly to pipeline stage in case it is used for Load instruction
    // Forwarded outputs are also used in the M unit to avoid data hazards
    assign op2_selected = op2_forwarded;
    assign op1_selected = op1_forwarded;

    always @(*) begin
        case (opcode)
            7'b1100111: begin
                op1_alu = pc;
                op2_alu = 32'd4;
            end
            7'b1101111: begin
                op1_alu = pc;
                op2_alu = 32'd4;
            end
            7'b0110111: begin
                op1_alu = 32'h00000000;
                op2_alu = immediate;
            end
            7'b0010111: begin
                op1_alu = pc;
                op2_alu = immediate;
            end
            default: begin
                op1_alu = op1_forwarded;
                op2_alu = ex_alu_src ? immediate : op2_forwarded;
            end      
        endcase
    end
        
    assign op1_valid = op1_alu;
    assign op2_valid = op2_alu;

    // Instantiate the PC Jump Module
    pc_jump pc_jump_inst (
        .pred_valid(pred_valid),
        .predicted_pc(predicted_pc),
        .pc(pc),
        .immediate(immediate),
        .op1(op1_forwarded),
        .opcode(opcode),
        .func3(func3),
        .lt_flag(lt_flag),
        .ltu_flag(ltu_flag),
        .zero_flag(zero_flag),
        .predictedTaken(predictedTaken),
        .update_pc(pc_jump_addr),
        .jump_addr(calc_jump_addr),
        .modify_pc(jump_en),
        .update_btb(update_btb)
    );

    // Instantiate the ALU Controller
    alu_control alu_control_inst (
        .func3(func3),
        .func7(func7),
        .opcode(opcode),
        .ALUControl(ALUControl)
    );   

    // Instantiate the ALU module
    alu alu_inst (
        .op1(op1_valid),
        .op2(op2_valid),
        .ALUControl(ALUControl),
        .result(alu_result),
        .lt_flag(lt_flag),
        .ltu_flag(ltu_flag),
        .zero_flag(zero_flag)
    );

    // Check if we have data from M unit
    assign result = alu_result;
    assign wb_reg_file = ex_wb_reg_file;
    assign wb_rd = pipeline_flush ? 0 : alu_rd;

endmodule