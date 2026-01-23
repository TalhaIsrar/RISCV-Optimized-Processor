module riscv_soc_top(
    input logic clk,
    input logic rst,
    output logic [31:0] wb_result,
    output logic [31:0] ex_result,
    output logic pc_en,
    output logic led
);
    // EX/IF Signals
    logic [31:0] ex_if_pc_jump_addr;
    logic ex_jump_en;

    // Branch Target Buffer Signals
    logic [31:0] btb_target_pc;
    logic btb_pc_valid;
    logic btb_pc_predictTaken;
    logic btb_update;
    logic [31:0] btb_update_target;

    logic [31:0] id_predicted_pc, ex_predicted_pc;
    logic ex_pred_valid, id_pred_valid;

    // Hazard Unit Signals
    logic if_id_pipeline_flush;
    logic if_id_pipeline_en;
    logic id_ex_pipeline_flush;
    logic id_ex_pipeline_en;
    logic ex_mem_pipeline_flush;
    logic mem_wb_pipeline_en;
    logic invalid_inst;
    logic load_stall;
    logic m_type_inst;
    logic stall_axi;
    logic ex_if_jump_en;
    logic ex_mem_pipeline_en;

    // IF/ID Connection
    logic [31:0] if_instruction, id_instruction;
    logic [31:0] if_pc, id_pc;
    logic id_flush;

    // M Unit Connection
    logic [31:0] m_unit_op1;
    logic [31:0] m_unit_instruction;
    logic m_unit_invalid_inst;
    logic m_unit_ready;
    logic m_unit_wr;
    logic [31:0] m_unit_result;
    logic m_unit_busy;
    logic [4:0] m_unit_dest;

    // ID/EX Connection
    logic [31:0] ex_pc;
    logic [31:0] id_op1, ex_op1;
    logic [31:0] id_op2, ex_op2;
    logic [4:0]  id_rs1, ex_rs1;
    logic [4:0]  id_rs2, ex_rs2;
    logic [4:0]  id_wb_rd, ex_wb_rd;
    logic [31:0] id_immediate, ex_immediate;
    logic [6:0]  id_opcode, ex_opcode;
    logic        id_alu_src, ex_alu_src;
    logic [6:0]  id_func7, ex_func7;
    logic [2:0]  id_func3, ex_func3;
    logic        id_mem_write, ex_mem_write;
    logic [2:0]  id_mem_load_type, ex_mem_load_type;
    logic [1:0]  id_mem_store_type, ex_mem_store_type;
    logic        id_wb_load, ex_wb_load;
    logic        id_wb_reg_file, ex_wb_reg_file;
    logic        id_pred_taken, ex_pred_taken;
    logic        ex_forward_pipeline_flush;

    // Forwarding Unit Connection
    logic [1:0]  operand_a_cntl;
    logic [1:0]  operand_b_cntl;

    // EX/MEM Conncetion
    logic [4:0]  alu_rd;
    logic        alu_wb;
    logic [31:0] mem_result;
    logic [31:0] ex_op2_selected, mem_op2_selected;
    logic [4:0]  mem_wb_rd;
    logic        mem_memory_write;
    logic        mem_memory_read;
    logic [2:0]  mem_memory_load_type;
    logic [1:0]  mem_memory_store_type;
    logic        mem_wb_load;
    logic        mem_wb_reg_file;
    logic        valid_addr;

    // MEM/WB Connection
    logic [31:0] mem_read_data, wb_read_data;
    logic [31:0] mem_calculated_result, wb_calculated_result;
    logic [4:0]  wb_rd;
    logic        wb_reg_file;
    logic        wb_load;

    // Instantiate the Fetch stage module
    fetch_stage fetch_stage_inst (
        .clk(clk),
        .rst(rst),
        .pc_en(pc_en),
        .flush(if_id_pipeline_flush),
        .pc_jump_addr(ex_if_pc_jump_addr),
        .jump_en(ex_if_jump_en),
        .btb_target_pc(btb_target_pc),
        .btb_pc_valid(btb_pc_valid),
        .btb_pc_predictTaken(btb_pc_predictTaken),
        .instruction(if_instruction),
        .pc(if_pc)
    );

    // Instantiate the Branch Target Buffer module
    btb btb_inst (
        .clk(clk),
        .rst(rst),
        .pc(if_pc),
        .update_pc(ex_pc),
        .update(btb_update), // Replace btb_update by 1'b0 to disconnect BTB
        .update_target(btb_update_target), // Replace btb_update_target by 1'b0 to disconnect BTB
        .mispredicted(ex_if_jump_en),
        .target_pc(btb_target_pc),
        .valid(btb_pc_valid),
        .predictedTaken(btb_pc_predictTaken)
    );

    // Instantiate the IF/ID pipeline module
    if_id_pipeline if_id_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .pipeline_flush(if_id_pipeline_flush),
        .pipeline_en(if_id_pipeline_en),
        .if_flush(if_id_pipeline_flush),
        .if_pc(if_pc),
        .if_predicted_pc(btb_target_pc),
        .if_instruction(if_instruction),
        .if_pred_taken(btb_pc_predictTaken),
        .if_pred_valid(btb_pc_valid),
        .id_flush(id_flush),
        .id_pc(id_pc),
        .id_instruction(id_instruction),
        .id_predicted_pc(id_predicted_pc),
        .id_pred_taken(id_pred_taken),
        .id_pred_valid(id_pred_valid)
    );

    // Instantiate the Decode stage module
    decode_stage decode_stage_inst (
        .clk(clk),
        .rst(rst),
        .id_flush(id_flush),
        .instruction_in(id_instruction),
        .reg_file_wr_en(wb_reg_file),   // Come from WB stage
        .reg_file_wr_addr(wb_rd), // Come from WB stage
        .reg_file_wr_data(wb_result), // Come from WB stage
        .op1(id_op1),
        .op2(id_op2),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_wb_rd),
        .immediate(id_immediate),
        .opcode(id_opcode),
        .alu_src(id_alu_src),
        .invalid_inst(invalid_inst),
        .m_type_inst(m_type_inst),
        .func7(id_func7),
        .func3(id_func3),
        .mem_write(id_mem_write),
        .mem_load_type(id_mem_load_type),
        .mem_store_type(id_mem_store_type),
        .wb_load(id_wb_load),
        .wb_reg_file(id_wb_reg_file)
    );

    // Instantiate the ID/EX pipeline module
    id_ex_pipeline id_ex_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .pipeline_flush(id_ex_pipeline_flush),
        .pipeline_en(id_ex_pipeline_en),
        .id_instruction(id_instruction),
        .id_pc(id_pc),
        .id_op1(id_op1),
        .id_op2(id_op2),
        .id_immediate(id_immediate),
        .id_opcode(id_opcode),
        .id_alu_src(id_alu_src),
        .id_func7(id_func7),
        .id_func3(id_func3),
        .id_mem_write(id_mem_write),
        .id_mem_load_type(id_mem_load_type),
        .id_mem_store_type(id_mem_store_type),
        .id_wb_load(id_wb_load),
        .id_wb_reg_file(id_wb_reg_file),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_wb_rd(id_wb_rd),
        .id_pred_taken(id_pred_taken),
        .id_predicted_pc(id_predicted_pc),
        .id_pred_valid(id_pred_valid),

        .ex_forward_pipeline_flush(ex_forward_pipeline_flush),
        .ex_instruction(m_unit_instruction),
        .ex_pc(ex_pc),
        .ex_op1(ex_op1),
        .ex_op2(ex_op2),
        .ex_immediate(ex_immediate),
        .ex_opcode(ex_opcode),
        .ex_alu_src(ex_alu_src),
        .ex_func7(ex_func7),
        .ex_func3(ex_func3),
        .ex_mem_write(ex_mem_write),
        .ex_mem_load_type(ex_mem_load_type),
        .ex_mem_store_type(ex_mem_store_type),
        .ex_wb_load(ex_wb_load),
        .ex_wb_reg_file(ex_wb_reg_file),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_wb_rd(ex_wb_rd),
        .ex_pred_taken(ex_pred_taken),
        .ex_predicted_pc(ex_predicted_pc),
        .ex_pred_valid(ex_pred_valid)
    );

    // Instantiate the Forwading Unit module
    forwarding_unit forwarding_unit_inst (
        .rs1(ex_rs1),
        .rs2(ex_rs2),
        .rd_mem(mem_wb_rd),
        .rd_wb(wb_rd),
        .reg_file_wr_mem(mem_wb_reg_file),
        .reg_file_wr_wb(wb_reg_file),
        .operand_a_cntl(operand_a_cntl),
        .operand_b_cntl(operand_b_cntl)
    );

    // Instantiate the Execute stage module
    execute_stage execute_stage_inst (
        .pred_valid(ex_pred_valid),
        .predicted_pc(ex_predicted_pc),
        .pc(ex_pc),
        .op1(ex_op1),
        .op2(ex_op2),
        .pipeline_flush(ex_forward_pipeline_flush),
        .immediate(ex_immediate),
        .func7(ex_func7),
        .func3(ex_func3),
        .opcode(ex_opcode),
        .ex_alu_src(ex_alu_src),
        .predictedTaken(ex_pred_taken),
        .ex_wb_reg_file(ex_wb_reg_file),
        .alu_rd(ex_wb_rd),
        .operand_a_forward_cntl(operand_a_cntl),
        .operand_b_forward_cntl(operand_b_cntl),
        .data_forward_mem(mem_result),
        .data_forward_wb(wb_result),
        .result(ex_result),
        .op1_selected(m_unit_op1),
        .op2_selected(ex_op2_selected),
        .pc_jump_addr(ex_if_pc_jump_addr),
        .jump_en(ex_if_jump_en),
        .update_btb(btb_update),
        .calc_jump_addr(btb_update_target),
        .wb_rd(alu_rd),
        .wb_reg_file(alu_wb)
    );

    // Instantiate the Hazard Unit module
    hazard_unit hazard_unit_inst (
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .opcode(id_opcode),
        .ex_rd(ex_wb_rd),
        .ex_load_inst(ex_wb_load),
        .jump_branch_taken(ex_if_jump_en),
        .invalid_inst(invalid_inst),
        .stall(0),
        .if_id_pipeline_flush(if_id_pipeline_flush),
        .if_id_pipeline_en(if_id_pipeline_en),
        .id_ex_pipeline_flush(id_ex_pipeline_flush),
        .id_ex_pipeline_en(id_ex_pipeline_en),
        .pc_en(pc_en),
        .load_stall(load_stall),
        .ex_mem_pipeline_en(ex_mem_pipeline_en)
    );

    // Instantiate the EX/MEM pipeline module
    ex_mem_pipeline ex_mem_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .pipeline_flush(0),
        .pipeline_en(1),
        .ex_result(ex_result),
        .ex_op2_selected(ex_op2_selected),
        .ex_memory_write(ex_mem_write),
        .ex_memory_load_type(ex_mem_load_type),
        .ex_memory_store_type(ex_mem_store_type),
        .ex_wb_load(ex_wb_load),
        .ex_wb_reg_file(alu_wb),
        .ex_wb_rd(alu_rd),

        .mem_result(mem_result),
        .mem_op2_selected(mem_op2_selected),
        .mem_memory_write(mem_memory_write),
        .mem_memory_load_type(mem_memory_load_type),
        .mem_memory_store_type(mem_memory_store_type),
        .mem_wb_load(mem_wb_load),
        .mem_wb_reg_file(mem_wb_reg_file),
        .mem_wb_rd(mem_wb_rd)
    );

    // Instantiate the Memory stage module
    mem_stage mem_stage_inst (
        .clk(clk),
        .rst(rst),
        .result(mem_result),
        .op2_data(mem_op2_selected),
        .mem_write(mem_memory_write),
        .store_type(mem_memory_store_type),
        .load_type(mem_memory_load_type),
        .read_data(mem_read_data),
        .calculated_result(mem_calculated_result)
    );

    // Instantiate the MEM/WB pipeline module
    mem_wb_pipeline mem_wb_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .mem_wb_load(mem_wb_load),
        .mem_wb_reg_file(mem_wb_reg_file),
        .mem_read_data(mem_read_data),
        .mem_calculated_result(mem_calculated_result),
        .mem_wb_rd(mem_wb_rd),
        .wb_load(wb_load),
        .wb_reg_file(wb_reg_file),
        .wb_read_data(wb_read_data),
        .wb_calculated_result(wb_calculated_result),
        .wb_rd(wb_rd)
    );

    // Instantiate the Write Back stage module
    writeback_stage writeback_stage_inst (
        .wb_load(wb_load),
        .mem_read_data(wb_read_data),
        .alu_result(wb_calculated_result),
        .wb_result(wb_result)
    );

endmodule