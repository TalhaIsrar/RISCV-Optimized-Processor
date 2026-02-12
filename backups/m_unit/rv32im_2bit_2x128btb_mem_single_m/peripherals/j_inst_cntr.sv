module j_inst_cntr(
    input clk,
    input rst,
    input j_inst,
    output logic [31:0] j_inst_cntr 
);

    always @(posedge clk) begin
        if (rst)
            j_inst_cntr <= 0;
        else if (j_inst) 
            j_inst_cntr <= j_inst_cntr + 1;
    end

endmodule
