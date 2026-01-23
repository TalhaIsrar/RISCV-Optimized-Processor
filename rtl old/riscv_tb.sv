`timescale 1ns/1ps
module riscv_tb;

  // Clock and Reset
  logic clk;
  logic rst;
  logic led;
  logic pc_en;
  logic [31:0] wb_result;
  logic [31:0] ex_result;

    // Instantiate the core
    riscv_soc_top uut (
        .clk(clk),
        .rst(rst),
        .wb_result(wb_result),
        .ex_result(ex_result),
        .pc_en(pc_en),
        .led(led)
    );

  initial
  begin
    $dumpfile("");
    $dumpvars(0, TB);

  end

endmodule
