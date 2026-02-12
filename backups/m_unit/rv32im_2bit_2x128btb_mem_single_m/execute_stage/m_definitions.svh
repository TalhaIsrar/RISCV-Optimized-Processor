`ifndef M_DEFINITIONS_H
`define M_DEFINITIONS_H
typedef logic [2:0] func3;

// Definitions of M operations
`define MUL  3'b000 // multiplication returning 32 lower bits
`define MULH 3'b001 // multiplication (  signed x   signed) sending 32 upper bits
`define MULHSU 3'b010 // multiplication (  signed x unsigned) sending 32 upper bits
`define MULHU 3'b011 // multiplication (unsigned x unsigned) sending 32 upper bits
`define DIV  3'b100 //   signed division
`define DIVU 3'b101 // unsigned division
`define REM  3'b110 // remainder of   signed division
`define REMU 3'b111 // remainder of unsigned division

// detect whether it is a multiplication
function logic is_mult(func3 f3);
    return f3[2]==0;
endfunction
// detect whether it is a division
function logic is_div(func3 f3);
    return f3[2]==1 && f3[1]==0;
endfunction
// detect whether it is a remainder
function logic is_rem(func3 f3);
    return f3[2]==1 && f3[1]==1;
endfunction

// Function to determine whether a number is negative (MSB bit check)
function logic is_negative(unsigned [31:0] value);
    return value[31];
endfunction

`define M_ALU_MUL 3'd0
`define M_ALU_DIV 3'd1
`define M_ALU_REM 3'd2
`define M_ALU_ZERO 3'd3



`endif // M_DEFINITIONS_H