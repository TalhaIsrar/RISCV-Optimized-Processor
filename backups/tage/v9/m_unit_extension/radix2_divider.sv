module radix2_divider #(
    parameter ITERS_PER_CYCLE = 1,  //Can set as 1,2,4,8,16 - Reduces FMAX
    parameter COUNT = (32/ITERS_PER_CYCLE) - 1
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [31:0] dividend,
    input  logic [31:0] divisor,
    input               is_signed,

    output logic [31:0] quotient,
    output logic [31:0] remainder,
    output logic        done,
    output logic        busy
);

    logic load, iterate, finish;
    logic special_case;
    logic [31:0] special_q, special_r;

    div_datapath #(.ITERS_PER_CYCLE(ITERS_PER_CYCLE)) dp (
        .clk(clk),
        .rst(rst),
        .load(load),
        .iterate(iterate),
        .finish(finish),
        .is_signed(is_signed),
        .dividend(dividend),
        .divisor(divisor),
        .special_case(special_case),
        .special_q(special_q),
        .special_r(special_r),
        .quotient(quotient),
        .remainder(remainder)
    );

    div_controller #(.COUNT(COUNT)) ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .is_signed(is_signed),
        .load(load),
        .iterate(iterate),
        .finish(finish),
        .done(done),
        .busy(busy),
        .special_case(special_case),
        .special_q(special_q),
        .special_r(special_r)
    );

endmodule
