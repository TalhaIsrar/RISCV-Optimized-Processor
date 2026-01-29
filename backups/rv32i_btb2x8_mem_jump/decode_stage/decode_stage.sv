module decode_stage(
    input logic clk,
    input logic rst,
    input logic id_flush,
    input logic [31:0] instruction_in,
    input logic reg_file_wr_en,
    input logic [4:0] reg_file_wr_addr,
    input logic [31:0] reg_file_wr_data,
    
    output logic [31:0] op1,
    output logic [31:0] op2,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [31:0] immediate,
    output logic alu_src,
    output logic invalid_inst,
    output logic m_type_inst,
    output logic [6:0] func7,
    output logic [2:0] func3,
    output logic s_type_inst,
    output logic wb_load,
    output logic wb_reg_file,
    output [8:0] decoded_instruction
);
    wire [31:0] instruction;

    assign instruction = instruction_in;

    wire [6:0] opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign func7 = instruction[31:25];
    assign func3 = instruction[14:12];

    // decoded_instruction = {r_type_inst, i_type_inst, s_type_inst, wb_load, u_type_inst, b_type_inst, j_type_inst, aupic_inst, jalr_inst};

    wire [31:0] imm_s = decoded_instruction[6] ? {{20{instruction[31]}}, instruction[31:25], instruction[11:7]} : '0;
    wire [31:0] imm_j = decoded_instruction[2] ?  {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0} : '0;
    wire [31:0] imm_b = decoded_instruction[3] ?  {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0} : '0;
    wire [31:0] imm_u = decoded_instruction[4] || decoded_instruction[1] ?  {instruction[31:12], `ZERO_12BIT} : '0;
    wire [31:0] imm_i = decoded_instruction[0] || decoded_instruction[5]|| decoded_instruction[7]?  {{20{instruction[31]}}, instruction[31:20]} : '0;

    assign immediate = imm_s | imm_j | imm_b | imm_u | imm_i;

    // Instantiate the controller module
    decode_controller decode_controller_inst (
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .ex_alu_src(alu_src),
        .s_type_inst(s_type_inst),
        .wb_load(wb_load),
        .wb_reg_file(wb_reg_file),
        .invalid_inst(invalid_inst),
        .m_type_inst(m_type_inst),
        .decoded_instruction(decoded_instruction)
    );

    // Instantiate the register file module
    register_file register_file_inst (
        .clk(clk),
        .wr_en(reg_file_wr_en),
        .wr_addr(reg_file_wr_addr),
        .wr_data(reg_file_wr_data),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .op1(op1),
        .op2(op2)
    );


endmodule