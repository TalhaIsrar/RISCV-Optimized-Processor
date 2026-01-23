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
    logic r_type_inst;
    logic i_type_inst;
    logic wb_inst;
    logic u_type_inst;
    logic b_type_inst;
    logic j_type_inst;
    logic aupic_inst;
    logic jalr_inst;

    assign wb_inst = (opcode == 7'b0110011);
    assign r_type_inst = (wb_inst && (func7 == 7'b0000000 || func7 == 7'b0100000));
    assign i_type_inst = (opcode == 7'b0010011);
    assign mem_write = (opcode == 7'b0100011);
    assign wb_load = (opcode == 7'b0000011);
    assign m_type_inst = (wb_inst && (func7 == 7'b0000001));
    assign u_type_inst = (opcode == 7'b0110111);
    assign b_type_inst = (opcode == 7'b1100011);
    assign j_type_inst = (opcode == 7'b1101111);
    assign aupic_inst = ( opcode == 7'b0010111);
    assign jalr_inst = (opcode == 7'b1100111);

    assign ex_alu_src  = i_type_inst || wb_load || mem_write ||
                          u_type_inst ||aupic_inst || jalr_inst;

    assign wb_reg_file  = wb_inst || i_type_inst || wb_load ||
                          u_type_inst ||aupic_inst || jalr_inst || j_type_inst;
                         
    assign invalid_inst = !(r_type_inst || ex_alu_src ||
                            b_type_inst || j_type_inst);

endmodule