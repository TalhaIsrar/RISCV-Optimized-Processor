module timer(
    input clk,
    input rst,
    output logic [31:0] cycle_count 
);

    always @(posedge clk) begin
        if (rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

endmodule
