module decode_controller (
    input logic [6:0] opcode,
    input logic [2:0] func3,
    input logic [6:0] func7,
    output logic ex_alu_src,
    output logic mem_write,
    output logic wb_load,
    output logic wb_reg_file,
    output logic invalid_inst,
    output logic m_type_inst
);
    wire r_type_inst;
    wire i_type_inst;
    wire wb_inst;
    wire u_type_inst;
    wire b_type_inst;
    wire j_type_inst;
    wire aupic_inst;
    wire jalr_inst;

    assign wb_inst = (opcode == `OPCODE_RTYPE);
    assign r_type_inst = (wb_inst && (func7 == `FUNC7_ADD || func7 == `FUNC7_SUB));
    assign i_type_inst = (opcode == `OPCODE_ITYPE);
    assign mem_write = (opcode == `OPCODE_STYPE);
    assign wb_load = (opcode == `OPCODE_ILOAD);
    assign m_type_inst = (wb_inst && (func7 == `FUNC7_M_UNIT));
    assign u_type_inst = (opcode == `OPCODE_UTYPE);
    assign b_type_inst = (opcode == `OPCODE_BTYPE);
    assign j_type_inst = (opcode == `OPCODE_JTYPE);
    assign aupic_inst = ( opcode == `OPCODE_AUIPC);
    assign jalr_inst = (opcode == `OPCODE_IJALR);

    assign ex_alu_src  = i_type_inst || wb_load || mem_write ||
                          u_type_inst ||aupic_inst || jalr_inst;

    assign wb_reg_file  = wb_inst || i_type_inst || wb_load ||
                          u_type_inst ||aupic_inst || jalr_inst || j_type_inst;
                         
    assign invalid_inst = !(r_type_inst || ex_alu_src ||
                            b_type_inst || j_type_inst);

endmodule