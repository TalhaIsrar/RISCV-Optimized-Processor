module alu_control(
    input logic [2:0] func3,
    input logic [6:0] func7,
    input logic [8:0] decoded_instruction,
    output logic [3:0] ALUControl
);
    // Pre-decode special cases to shorten logic depth
    wire is_sub = func7[5] && decoded_instruction[8];
    wire is_sra = func7[5];

    always_comb begin
        if (decoded_instruction[8] || decoded_instruction[7]) begin
            // R-type or I-type
            case (func3)
                3'b000: ALUControl = is_sub ? 4'b0001 : 4'b0000;
                3'b001: ALUControl = 4'b0101;
                3'b010: ALUControl = 4'b1000;
                3'b011: ALUControl = 4'b1001;
                3'b100: ALUControl = 4'b0100;
                3'b101: ALUControl = is_sra ? 4'b0111 : 4'b0110;
                3'b110: ALUControl = 4'b0011;
                3'b111: ALUControl = 4'b0010;
                default: ALUControl = 4'b0000; // safety fallback
            endcase
        end
        else if (decoded_instruction[3]) begin
            // B-type
            case (func3)
                3'b100, 3'b101: ALUControl = 4'b1000;
                3'b110, 3'b111: ALUControl = 4'b1001;
                default: ALUControl = 4'b0001;
            endcase
        end
        else begin
            ALUControl = 4'b0000; // load/store/LUI/AUIPC
        end
    end


endmodule