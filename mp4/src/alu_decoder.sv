module alu_decoder (
  input logic  [2:0]  funct3,
  input logic  [6:0]  funct7,
  input logic  [1:0]  alu_op,
  output logic [3:0]  alu_ctrl
);

  always_comb begin
    unique case (alu_op)
      2'b00: begin
        alu_ctrl = 4'b0000; // ADD
      end
      2'b01: begin
        alu_ctrl = 4'b0001; // SUB
      end
      2'b10: begin
        unique case (funct3)
          3'b000: begin
            alu_ctrl = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; 
          end
          3'b001: begin
            alu_ctrl = 4'b0111; // SLL
          end
          3'b010: begin
            alu_ctrl = 4'b0101; // SLT
          end
          3'b011: begin
            alu_ctrl = 4'b0110; // SLTU
          end
          3'b100: begin
            alu_ctrl = 4'b0100; // XOR
          end
          3'b101: begin
            alu_ctrl = (funct7 == 7'b0100000) ? 4'b1001 : 4'b1000; // SRA -- SRL
          end
          3'b110: begin
            alu_ctrl = 4'b0011; // OR
          end
          3'b111: begin
            alu_ctrl = 4'b0010; // AND
          end
          default: alu_ctrl = 4'b0000;
        endcase
      end
      2'b11: begin
        unique case (funct3)
            3'b000: alu_ctrl = 4'b0001;
            3'b001: alu_ctrl = 4'b0001;
            3'b100: alu_ctrl = 4'b0101;
            3'b101: alu_ctrl = 4'b0101;
            3'b110: alu_ctrl = 4'b0110;
            3'b111: alu_ctrl = 4'b0110;
        endcase
      end
      default: alu_ctrl = 4'b0000;
    endcase
  end

endmodule
