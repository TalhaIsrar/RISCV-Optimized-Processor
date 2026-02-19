`include "defines.svh"

module decode_controller (
    input logic [6:0] opcode,
    input logic [2:0] func3,
    input logic [6:0] func7,
    output logic ex_alu_src,
    output logic s_type_inst,
    output logic wb_load,
    output logic wb_reg_file,
    output logic invalid_inst,
    output logic m_type_inst,
    output [8:0] decoded_instruction
);
    wire r_type_inst;
    wire i_type_inst;
    wire add_sub_inst;
    wire u_type_inst;
    wire b_type_inst;
    wire j_type_inst;
    wire aupic_inst;
    wire jalr_inst;

    assign r_type_inst = (opcode == `OPCODE_RTYPE);
    assign i_type_inst = (opcode == `OPCODE_ITYPE);
    assign s_type_inst = (opcode == `OPCODE_STYPE);
    assign wb_load = (opcode == `OPCODE_ILOAD);
    assign u_type_inst = (opcode == `OPCODE_UTYPE);
    assign b_type_inst = (opcode == `OPCODE_BTYPE);
    assign j_type_inst = (opcode == `OPCODE_JTYPE);
    assign aupic_inst = ( opcode == `OPCODE_AUIPC);
    assign jalr_inst = (opcode == `OPCODE_IJALR);

    assign decoded_instruction = {r_type_inst, i_type_inst, s_type_inst, wb_load, u_type_inst, b_type_inst, j_type_inst, aupic_inst, jalr_inst};

    assign add_sub_inst = (r_type_inst && (func7 == `FUNC7_ADD || func7 == `FUNC7_SUB));
    assign m_type_inst = (r_type_inst && (func7 == `FUNC7_M_UNIT));

    assign ex_alu_src  = i_type_inst || wb_load || s_type_inst ||
                          u_type_inst ||aupic_inst || jalr_inst;

    assign wb_reg_file  = r_type_inst || i_type_inst || wb_load ||
                          u_type_inst ||aupic_inst || jalr_inst || j_type_inst;
                         
    assign invalid_inst = !(add_sub_inst || ex_alu_src ||
                            b_type_inst || j_type_inst);

endmodule