module alu_decoder (
  input logic  [2:0]  funct3,
  input logic  [6:0]  funct7,
  input logic  [2:0]  alu_op,
  output logic [4:0]  alu_ctrl
);

  always_comb begin
    unique case (alu_op)
      3'b000: begin
        alu_ctrl = 5'b00000; // ADD
      end
      3'b001: begin
        alu_ctrl = 5'b00001; // SUB
      end
      3'b010: begin
        unique case (funct3)
          3'b000: begin
            alu_ctrl = (funct7 == 7'b0100000) ? 5'b00001 : 5'b00000; 
          end
          3'b001: begin
            alu_ctrl = 5'b00111; // SLL
          end
          3'b010: begin
            alu_ctrl = 5'b00101; // SLT
          end
          3'b011: begin
            alu_ctrl = 5'b00110; // SLTU
          end
          3'b100: begin
            alu_ctrl = 5'b00100; // XOR
          end
          3'b101: begin
            alu_ctrl = (funct7 == 7'b0100000) ? 5'b01001 : 5'b01000; // SRA -- SRL
          end
          3'b110: begin
            alu_ctrl = 5'b00011; // OR
          end
          3'b111: begin
            alu_ctrl = 5'b00010; // AND
          end
          default: alu_ctrl = 5'b00000;
        endcase
      end
      3'b011: begin
        unique case (funct3)
            3'b000: alu_ctrl = 5'b00001;
            3'b001: alu_ctrl = 5'b00001;
            3'b100: alu_ctrl = 5'b00101;
            3'b101: alu_ctrl = 5'b00101;
            3'b110: alu_ctrl = 5'b00110;
            3'b111: alu_ctrl = 5'b00110;
        endcase
      end
      3'b100: begin // RV32M
        unique case (funct3)
          3'b000: alu_ctrl = 5'b01010;
          3'b001: alu_ctrl = 5'b01011;
          3'b010: alu_ctrl = 5'b01100;
          3'b011: alu_ctrl = 5'b01101;
          3'b100: alu_ctrl = 5'b01110;
          3'b101: alu_ctrl = 5'b01111;
          3'b110: alu_ctrl = 5'b10000;
          3'b111: alu_ctrl = 5'b10001;
        endcase
      end
      default: alu_ctrl = 5'b00000;
    endcase
  end

endmodule
