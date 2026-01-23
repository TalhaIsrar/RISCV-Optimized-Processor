module decode_stage(
    input clk,
    input rst,
    input id_flush,
    input [31:0] instruction_in,
    input reg_file_wr_en,
    input [4:0] reg_file_wr_addr,
    input [31:0] reg_file_wr_data,
    
    output wire [31:0] op1,
    output wire [31:0] op2,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,
    output reg [31:0] immediate,
    output wire [6:0] opcode,
    output wire alu_src,
    output wire invalid_inst,
    output wire m_type_inst,
    output wire [6:0] func7,
    output wire [2:0] func3,
    output wire mem_write,
    output wire [2:0] mem_load_type,
    output wire[1:0] mem_store_type,
    output wire wb_load,
    output wire wb_reg_file
);
    wire [31:0] instruction;

    assign instruction = id_flush ? 32'h00000013 : instruction_in;

    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign func7 = instruction[31:25];
    assign func3 = instruction[14:12];

    always @(*) begin
        case (opcode)
            7'b0100011: 
                immediate = {{20{instruction[31]}},instruction[31:25],instruction[11:7]}; 
            7'b1101111: 
                immediate = {{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
            7'b1100011: 
                immediate = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
            7'b0110111: 
                immediate = {instruction[31:12],12'h000};
            7'b0010111: 
                immediate = {instruction[31:12],12'h000};
            default:       
                immediate = {{20{instruction[31]}},instruction[31:20]};
        endcase
    end
    
    // Instantiate the controller module
    decode_controller decode_controller_inst (
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .ex_alu_src(alu_src),
        .mem_write(mem_write),
        .mem_load_type(mem_load_type),
        .mem_store_type(mem_store_type),
        .wb_load(wb_load),
        .wb_reg_file(wb_reg_file),
        .invalid_inst(invalid_inst),
        .m_type_inst(m_type_inst)
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