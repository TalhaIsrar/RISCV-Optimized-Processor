module mispred_inst_cntr(
    input clk,
    input rst,
    input misprediction,
    output logic [31:0] mispred_inst_cntr 
);

    always @(posedge clk) begin
        if (rst)
            mispred_inst_cntr <= 0;
        else if (misprediction) 
            mispred_inst_cntr <= mispred_inst_cntr + 1;
    end

endmodule
