module if_id_pipeline(
    input logic clk,
    input logic rst,
    input logic pipeline_flush,
    input logic pipeline_en,
        
    input logic if_flush,
    input logic [31:0] if_pc,
    input logic [31:0] if_instruction,
    input logic if_pred_taken,
    input logic if_pred_valid,
    input logic [31:0] if_predicted_pc,

    output logic id_flush,
    output logic [31:0] id_pc,
    output logic [31:0] id_instruction,
    output logic [31:0] id_predicted_pc,
    output logic id_pred_taken,
    output logic id_pred_valid
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            id_pc <= 32'h00000000;
            id_pred_taken <= 1'b0;
            id_flush <= 1'b0;
            id_predicted_pc <= 0;
            id_pred_valid <= 0;
        end else if (pipeline_flush) begin
            id_pc <= id_pc;
            id_pred_taken <= 1'b0;
            id_flush <= if_flush;
            id_predicted_pc <= 0;
            id_pred_valid <= 0;
        end else if (pipeline_en) begin
            id_pc <= if_pc;
            id_pred_taken <= if_pred_taken;  
            id_flush <= if_flush; 
            id_predicted_pc <= if_predicted_pc;
            id_pred_valid <= if_pred_valid;
        end
    end

    // Instruction is passed directly from fetch stage to decode stage because
    // register already in instruction memory module
    assign id_instruction = if_instruction;

endmodule