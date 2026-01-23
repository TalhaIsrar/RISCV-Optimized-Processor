module alu_control(
    input [2:0] func3,
    input [6:0] func7,
    input [6:0] opcode,
    output reg [3:0] ALUControl
);
    // Pre-decode special cases to shorten logic depth
    wire is_sub = func7[5] && opcode[5];
    wire is_sra = func7[5];

    always @(*) begin
        case (opcode)
            7'b0110011,
            7'b0010011: begin
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

            7'b1100011: begin
                case (func3)
                    3'b100,
                    3'b101:   ALUControl = 4'b1000;   // signed compare
                    3'b110,
                    3'b111:  ALUControl = 4'b1001;  // unsigned compare
                    default:      ALUControl = 4'b0001;   // default branch compare
                endcase
            end

            default: ALUControl = 4'b0000; // Loads, stores, LUI, AUIPC, etc.
        endcase
    end

endmodule