module alu (
  input  logic [31:0]    SrcA,
  input  logic [31:0]    SrcB,
  input  logic [4:0]     ALUControl,
  input  logic [2:0]     Branch_Con,
  output logic [31:0]    ALUResult,
  output logic           zero
);

  logic [31:0] result;
  logic [63:0] product;

  always_comb begin
    unique case (ALUControl)
      5'b00000: begin // ADD
        result  = SrcA + SrcB;
      end
      5'b00001: begin // SUB
        result  = SrcA - SrcB;
      end
      5'b00010: begin // AND
        result  = SrcA & SrcB;
      end
      5'b00011: begin // OR
        result  = SrcA | SrcB;
      end
      5'b00100: begin // XOR
        result  = SrcA ^ SrcB;
      end
      5'b00101: begin // SLT
        result  = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
      end
      5'b00110: begin // SLTU
        result  = (SrcA < SrcB) ? 1 : 0;
      end
      5'b00111: begin // SLL
        result  = SrcA << SrcB[4:0];
      end
      5'b01000: begin // SRL
        result  = SrcA >> SrcB[4:0];
      end
      5'b01001: begin // SRA
        result  = $signed(SrcA) >>> SrcB[4:0];
      end
      5'b01010: begin // MUL
        product = ($signed(SrcA) * $signed(SrcB));
        result  = product[31:0];
      end
      5'b01011: begin // MULH
        product = ($signed(SrcA) * $signed(SrcB));
        result  = product[63:32];
      end
      5'b01100: begin // MULSU
        product = $signed({{32{SrcA[31]}}, SrcA}) * $unsigned({32'b0, SrcB}); // Had to finagle this to work correctly
        result  = product[63:32];
      end
      5'b01101: begin // MULU
        product = SrcA * SrcB;
        result  = product[63:32];
      end
      5'b01110: begin // DIV
        result  = $signed(SrcA) / $signed(SrcB);
      end
      5'b01111: begin // DIVU
        result  = SrcA / SrcB;
      end
      5'b10000: begin // REM
        result  = $signed(SrcA) % $signed(SrcB);
      end
      5'b10001: begin // REMU
        result  = SrcA % SrcB;
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
