module inst_cntr(
    input clk,
    input rst,
    input stall,
    input mispred,
    input enable,
    output logic [31:0] inst_cntr 
);

    always @(posedge clk) begin
        if (rst)
            inst_cntr <= 0;
        else if (mispred)
            inst_cntr <= inst_cntr - 2;
        else if (stall)
            inst_cntr <= inst_cntr;
        else if (!enable)
            inst_cntr <= inst_cntr;
        else 
            inst_cntr <= inst_cntr + 1;
    end

endmodule
