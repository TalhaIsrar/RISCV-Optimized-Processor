module execute_stage(
    input logic [31:0] pc,
    input logic [31:0] op1,
    input logic [31:0] op2,
    input logic pipeline_flush,
    input logic [31:0] immediate,
    input logic [6:0] func7,
    input logic [2:0] func3,
    input logic ex_alu_src,
    input logic ex_wb_reg_file,
    input logic [4:0] alu_rd,

    input [31:0] m_unit_result,
    input m_unit_wr,
    input m_unit_ready,
    input [4:0] m_unit_dest,
    
    input logic [1:0] rs1_forward_cntl,
    input logic [1:0] rs2_forward_cntl,
    input logic [31:0] data_forward_mem,
    input logic [31:0] data_forward_wb,
    input logic [8:0] decoded_instruction,

    output [31:0] result,
    output logic [31:0] op1_selected,
    output [31:0] op2_selected,
    output [4:0] wb_rd,
    output wb_reg_file,
    output logic [2:0] alu_flags
);

    logic [3:0] ALUControl;
    logic [31:0] op1_forwarded;
    logic [31:0] op2_forwarded;
    wire [31:0] op1_alu;
    wire [31:0] op2_alu;
    logic [31:0] alu_result;

    // Mux for forwarding operand 1
    always_comb begin
        case (rs1_forward_cntl)
            2'b01: op1_forwarded = data_forward_mem;
            2'b10:  op1_forwarded = data_forward_wb;
            default:      op1_forwarded = op1;
        endcase
    end

    // Mux for forwarding operand 2
    always_comb begin
        case (rs2_forward_cntl)
            2'b01: op2_forwarded = data_forward_mem;
            2'b10:  op2_forwarded = data_forward_wb;
            default:      op2_forwarded = op2;
        endcase
    end

    // Pass op2 directly to pipeline stage in case it is used for Load instruction
    // Forwarded outputs are also used in the M unit to avoid data hazards
    assign op2_selected = op2_forwarded;
    assign op1_selected = op1_forwarded;

    //decoded_instruction = {r_type_inst, i_type_inst, s_type_inst, wb_load, 
    //            u_type_inst, b_type_inst, j_type_inst, aupic_inst, jalr_inst};
    assign op2_alu = (decoded_instruction[0] || decoded_instruction[2]) ? 32'd4 :
                     (ex_alu_src ? immediate : op2_forwarded);

    assign op1_alu = (decoded_instruction[0] || decoded_instruction[1] || decoded_instruction[2]) ? pc :
                     (decoded_instruction[4] ? '0 : op1_forwarded);

    // Instantiate the ALU Controller
    alu_control alu_control_inst (
        .func3(func3),
        .func7(func7),
        .decoded_instruction(decoded_instruction),
        .ALUControl(ALUControl)
    );   

    // Instantiate the ALU module
    alu alu_inst (
        .op1(op1_alu),
        .op2(op2_alu),
        .ALUControl(ALUControl),
        .result(alu_result),
        .alu_flags(alu_flags)
    );

    // Check if we have data from M unit
    assign result = m_unit_ready ? m_unit_result : alu_result;
    assign wb_reg_file = m_unit_ready ? m_unit_wr : ex_wb_reg_file;
    assign wb_rd = m_unit_ready ? m_unit_dest : (pipeline_flush ? 5'b00000 : alu_rd);

endmodule