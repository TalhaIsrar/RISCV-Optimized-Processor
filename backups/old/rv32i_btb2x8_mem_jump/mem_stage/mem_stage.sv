module mem_stage(
    input logic clk,
    input logic rst,
    input logic [31:0] result,
    input logic [31:0] op2_data,
    input logic s_type_inst,
    input logic [2:0] load_type,

    input logic [31:0] predicted_pc,
    input logic pred_valid,
    input logic [31:0] pc,
    input logic [31:0] immediate,
    input logic [2:0] func3,
    input logic [2:0] alu_flags,
    input logic predictedTaken,
    input logic [8:0] decoded_instruction,
    input logic [31:0] op1_forwarded,

    output [31:0] pc_jump_addr,
    output logic jump_en,
    output logic btb_update,
    output logic [31:0] btb_update_target,

    output logic [31:0] read_data,
    output logic [31:0] calculated_result
);

    // Instantiate the PC Jump Module
    pc_jump pc_jump_inst (
        .pred_valid(pred_valid),
        .predicted_pc(predicted_pc),
        .pc(pc),
        .immediate(immediate),
        .op1(op1_forwarded),
        .func3(func3),
        .alu_flags(alu_flags),
        .predictedTaken(predictedTaken),
        .decoded_instruction(decoded_instruction),

        .update_pc(pc_jump_addr),
        .btb_update_target(btb_update_target),
        .modify_pc(jump_en),
        .btb_update(btb_update)
    );

    // Byte offset from address
    wire [1:0] byte_offset;
    assign byte_offset = result[1:0];

    // Generate byte strobe for axi4lite write channel
    logic [3:0] write_byte_strobe;
    logic [31:0] store_data_shifted;

    // Combinational block to convert store type and byte offset to byte enables
    always_comb begin
        case (load_type)
            3'b000: begin // SB
                write_byte_strobe = 4'b0001 << byte_offset;
                store_data_shifted = op2_data << (byte_offset * 8);
            end
            3'b001: begin // SH
                write_byte_strobe = byte_offset[1] ? 4'b1100 : 4'b0011;
                store_data_shifted = op2_data << (byte_offset[1] * 16);
            end
            3'b010: begin // SW
                write_byte_strobe = 4'b1111;
                store_data_shifted = op2_data;
            end
            default: begin
                write_byte_strobe = 4'b0000;
                store_data_shifted = op2_data;
            end
        endcase
    end

    logic [31:0] result_delay;
    logic [2:0] load_delay;
    logic [1:0] byte_offset_delay;
    // Next PC Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            result_delay <= '0; // Reset PC to 0
            load_delay <= '0;
            byte_offset_delay <= '0;
        end else begin
            result_delay <= result;
            load_delay <= load_type;
            byte_offset_delay <= byte_offset;
        end
    end

    wire [31:0] timer_val, mem_read_data;
    logic [31:0] final_read_data;
    wire uartWen, dmemWenFinal;
    wire [7:0] uartData;

    assign uartData = op2_data[7:0];
    assign uartWen = s_type_inst & (result == 32'hFFFF_0000);
    assign dmemWenFinal = s_type_inst && (!uartWen);
    wire read_timer = (result_delay == 32'hFFFF_FF00);
    assign read_data = read_timer ? timer_val : final_read_data;

    wire [31:0] addr = (result - 32'h10000000);


    data_memory dmem(
            .clk(clk),
            .s_type_inst(dmemWenFinal),
            .byte_en(write_byte_strobe),
            .write_addr(addr[17:0]),
            .read_addr(addr[17:0]),
            .write_data(store_data_shifted),
            .read_data(mem_read_data)
    );

    uart uartsim(
            .clk(clk),
            .rst(rst),
            .data(uartData),
            .wEn(uartWen)
          );

    timer Simtime(
          .clk(clk),
          .rst(rst),
          .cycle_count(timer_val)
    );



    // Perform byte/half-word selection and sign/zero extension *after* the read.
    always_comb begin
        case (load_delay)
            3'b000: begin // LB - load byte, sign extend
                case (byte_offset_delay)
                    2'b00: final_read_data = {{24{mem_read_data[7]}},  mem_read_data[7:0]};
                    2'b01: final_read_data = {{24{mem_read_data[15]}}, mem_read_data[15:8]};
                    2'b10: final_read_data = {{24{mem_read_data[23]}}, mem_read_data[23:16]};
                    2'b11: final_read_data = {{24{mem_read_data[31]}}, mem_read_data[31:24]};
                    default: final_read_data = 32'h00000000;
                endcase
            end
            3'b001: begin // LH - load halfword, sign extend
                if (byte_offset_delay[1] == 1'b0) final_read_data = {{16{mem_read_data[15]}}, mem_read_data[15:0]};
                else                        final_read_data = {{16{mem_read_data[31]}}, mem_read_data[31:16]};
            end
            3'b010: begin // LW - load word
                final_read_data = mem_read_data;
            end
            3'b100: begin // LBU - load byte, zero extend
                case (byte_offset_delay)
                    2'b00: final_read_data = {24'h0, mem_read_data[7:0]};
                    2'b01: final_read_data = {24'h0, mem_read_data[15:8]};
                    2'b10: final_read_data = {24'h0, mem_read_data[23:16]};
                    2'b11: final_read_data = {24'h0, mem_read_data[31:24]};
                    default: final_read_data = 32'h00000000;
                endcase
            end
            3'b101: begin // LHU - load halfword, zero extend
                if (byte_offset_delay[1] == 1'b0) final_read_data = {16'h0, mem_read_data[15:0]};
                else                        final_read_data = {16'h0, mem_read_data[31:16]};
            end
            default: final_read_data = mem_read_data;
        endcase
    end

    assign calculated_result = result;

endmodule