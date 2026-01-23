module decode_controller (
    input [6:0] opcode,
    input [2:0] func3,
    input [6:0] func7,
    output ex_alu_src,
    output mem_write,
    output reg [2:0] mem_load_type,
    output reg [1:0] mem_store_type,
    output wb_load,
    output wb_reg_file,
    output invalid_inst,
    output m_type_inst
);
    wire r_type_inst;
    wire i_type_inst;
    wire wb_inst;
    wire u_type_inst;
    wire b_type_inst;
    wire j_type_inst;
    wire aupic_inst;
    wire jalr_inst;

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

    always @(*) begin
        mem_store_type = 2'b11; // Disable writing
        if (mem_write) begin
            case (func3)
                3'b000: mem_store_type = 2'b00;
                3'b001: mem_store_type = 2'b01;
                3'b010: mem_store_type = 2'b10;
                default:mem_store_type = 2'b11; // Disable writing
            endcase
        end
    end

    always @(*) begin
        mem_load_type = func3; // Load full value

    end

endmodule