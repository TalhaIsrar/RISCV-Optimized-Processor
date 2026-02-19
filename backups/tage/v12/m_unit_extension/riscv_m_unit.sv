module riscv_m_unit(
	input logic clk, 
	input logic rst, 
	
	input logic valid,
	input logic[31:0] instruction,
	input logic[31:0] rs1,
	input logic[31:0] rs2,
    input logic[4:0] rd,

	output logic wr,
	output logic[31:0] result,
	output logic busy,
	output logic ready,
    output logic[4:0] result_dest
	);

    // Internal operands register to avoid data loss
    logic[31:0] rs1_r, rs2_r;
    logic[31:0] rs1_hold, rs2_hold;

    logic operand_select;
    logic[2:0] inst_type;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic is_m_ext, is_mul, is_div, is_rem, is_signed;
    logic [1:0] mul_op;
    logic mul_start, div_start, mul_done, div_done, mul_busy, div_busy;
    logic [31:0] mul_result, quotient, remainder;

    // Register to hold drs1 and rs2 if we have 2 consecutive m instructions
    always_ff @(posedge clk) begin
        if (rst) begin
            rs1_hold         <= 0;
            rs2_hold         <= 0;
            operand_select   <= 0;
        end else if (valid && !(busy || ready)) begin
            rs1_hold <= rs1;
            rs2_hold <= rs2;
            operand_select <= 1;
        end else if (ready) begin
            operand_select <= 0;
        end
    end


    // Select operands to pass (registered one is M followed by M otherwise normal ones)
    assign rs1_r = operand_select ? rs1_hold : rs1;
    assign rs2_r = operand_select ? rs2_hold : rs2;

    // Register to hold destination register ID
    always_ff @(posedge clk) begin
        if (rst) begin
            result_dest <= 5'd0;
            inst_type <= 0;
        end else if (valid && !busy) begin
            result_dest <= rd;
            inst_type <= {is_mul,is_div,is_rem};
        end
    end


    // Instruction Decode
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    assign is_m_ext = (opcode == 7'b0110011) &&
                      (funct7 == 7'b0000001);

    // Operation Classification
    assign is_mul = is_m_ext && (funct3 <= 3'b011);
    assign is_div = is_m_ext && (funct3 == 3'b100 || funct3 == 3'b101);
    assign is_rem = is_m_ext && (funct3 == 3'b110 || funct3 == 3'b111);
    assign mul_start = is_mul && valid && !busy && !ready;
    assign div_start = (is_div || is_rem) && !busy && valid && !ready;

    assign is_signed = (funct3 == 3'b100) || (funct3 == 3'b110); // Only needed for DIV and REM

    assign mul_op = funct3[1:0];

    mul_unit mul_unit_inst (
        .clk(clk),
        .rst(rst),
        .start(mul_start),
        .mul_op(mul_op),
        .rs1(rs1_r),
        .rs2(rs2_r),
        .result(mul_result),
        .done(mul_done),
        .busy(mul_busy)
    );

    radix2_divider #(.ITERS_PER_CYCLE(2)) radix4_divider_inst (
        .clk(clk),
        .rst(rst),
        .start(div_start),
        .dividend(rs1_r),
        .divisor(rs2_r),
        .is_signed(is_signed),
        .quotient(quotient),
        .remainder(remainder),
        .done(div_done),
        .busy(div_busy)
    );

    always_comb begin
        case(inst_type)
            3'b100: result = mul_result;
            3'b010: result = quotient;
            3'b001: result = remainder;
            default: result = 32'd0;
        endcase
    end

    assign ready = inst_type[2] ? mul_done : div_done;
    assign wr = ready;
    assign busy = inst_type[2] ? mul_busy : div_busy;

endmodule
