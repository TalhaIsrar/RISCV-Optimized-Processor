module mem_stage(
    input clk,
    input rst,
    input [31:0] result,
    input [31:0] op2_data,
    input mem_write,
    input [1:0] store_type,
    input [2:0] load_type,
    output reg [31:0] read_data,
    output wire [31:0] calculated_result
);
    // Byte offset from address
    wire [1:0] byte_offset;
    assign byte_offset = result[1:0];

    // Generate byte strobe for axi4lite write channel
    reg [3:0] write_byte_strobe;
    reg [31:0] store_data_shifted;

    // Combinational block to convert store type and byte offset to byte enables
    always @(*) begin
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

    reg [31:0] result_delay;
    reg [2:0] load_delay;
    reg [1:0] byte_offset_delay;
    // Next PC Register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result_delay <= 32'h00000000; // Reset PC to 0
            load_delay <= 3'b000;
            byte_offset_delay <= 0;
        end else begin
            result_delay <= result;
            load_delay <= load_type;
            byte_offset_delay <= byte_offset;
        end
    end

    wire [31:0] timer_val, mem_read_data;
    reg [31:0] final_read_data;
    wire uartWen, dmemWenFinal;
    wire [7:0] uartData;

    assign uartData = op2_data[7:0];
    assign uartWen = mem_write & (result == 32'hFFFF_0000);
    assign dmemWenFinal = mem_write && (!uartWen);
    wire read_timer = (result_delay == 32'hFFFF_FF00);
    assign read_data = read_timer ? timer_val : final_read_data;

    wire [31:0] addr = (result - 32'h10000000);


    data_memory dmem(
            .clk(clk),
            .rst(rst),
            .mem_write(dmemWenFinal),
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
    always @(*) begin
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