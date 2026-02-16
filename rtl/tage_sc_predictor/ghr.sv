module ghr #(parameter SIZE = 8) (
    input logic clk,
    input logic rst,
    input logic valid_inst,
    input logic branch_taken,
    output logic [SIZE-1:0] ghr_out
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            ghr_out <= 0;
        else if (valid_inst) 
            ghr_out <= {ghr_out[SIZE-2:0], branch_taken};
    end

endmodule