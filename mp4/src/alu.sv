module alu (
  input  logic [31:0]    SrcA,
  input  logic [31:0]    SrcB,
  input  logic [3:0]     ALUControl,
  input  logic [2:0]     Branch_Con,
  output logic [31:0]    ALUResult,
  output logic           zero
);

  logic [31:0] result;

  always_comb begin
    unique case (ALUControl)
      4'b0000: begin // ADD
        result = SrcA + SrcB;
      end
      4'b0001: begin // SUB
        result = SrcA - SrcB;
      end
      4'b0010: begin // AND
        result = SrcA & SrcB;
      end
      4'b0011: begin // OR
        result = SrcA | SrcB;
      end
      4'b0100: begin // XOR
        result = SrcA ^ SrcB;
      end
      4'b0101: begin // SLT
        result = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
      end
      4'b0110: begin // SLTU
        result = (SrcA < SrcB) ? 1 : 0;
      end
      4'b0111: begin // SLL
        result = SrcA << SrcB[4:0];
      end
      4'b1000: begin // SRL
        result = SrcA >> SrcB[4:0];
      end
      4'b1001: begin // SRA
        result = $signed(SrcA) >>> SrcB[4:0];
      end
      default: result = SrcA + SrcB;
    endcase
  end

  assign ALUResult = result;

  always_comb begin
    unique case (Branch_Con) 
      3'b000: zero = (result == 0);
      3'b001: zero = (result != 0);
      3'b010: zero = (result != 0);
      3'b011: zero = (result == 0);
      3'b100: zero = (result != 0);
      3'b101: zero = (result == 0);
      default: zero = 0;
    endcase
  end

endmodule
