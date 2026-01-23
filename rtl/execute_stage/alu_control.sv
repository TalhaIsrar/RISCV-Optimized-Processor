module alu_control(
    input logic [2:0] func3,
    input logic [6:0] func7,
    input logic [8:0] decoded_instruction,
    output logic [9:0] ALUControl
);
    // Pre-decode special cases to shorten logic depth
    wire is_sub = func7[5] && decoded_instruction[8];
    wire is_sra = func7[5];

    always_comb begin
        ALUControl = '0;
        if (decoded_instruction[8] || decoded_instruction[7]) begin
            // R-type or I-type
            case (func3)
                3'b000: begin
                    if (is_sub) ALUControl[1] = 1;
                    else        ALUControl[0] = 1;
                end
                3'b001:  ALUControl[5] = 1;
                3'b010:  ALUControl[8] = 1;
                3'b011:  ALUControl[9] = 1;
                3'b100:  ALUControl[4] = 1;
                3'b101: begin
                        if (is_sra) ALUControl[7] = 1;
                        else        ALUControl[6] = 1;
                    end
                3'b110:  ALUControl[3] = 1;
                3'b111:  ALUControl[2] = 1;
                default: ALUControl[0] = 1; // safety fallback
            endcase
        end
        else if (decoded_instruction[3]) begin
            // B-type
            case (func3)
                3'b100,
                3'b101:  ALUControl[8] = 1;   // signed compare
                3'b110,
                3'b111:  ALUControl[9] = 1;  // unsigned compare
                default: ALUControl[1] = 1;   // default branch compare
            endcase
        end
        else begin
            ALUControl[0] = 1; // Loads, stores, LUI, AUIPC, etc.
        end
    end


endmodule
