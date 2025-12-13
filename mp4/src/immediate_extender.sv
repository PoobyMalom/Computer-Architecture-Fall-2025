module immediate_extender (
  input logic     [31:7] immed,
  input logic     [2:0]  imm_src,
  output logic    [31:0] imm_ext
);

  reg [31:0] imm_out;

  always_comb begin
    unique case (imm_src)
      3'b000: begin // I-TYPE: instr[31:20] => sign-extend imm[11:0]
        imm_out = { {20{immed[31]}}, immed[31:20] }; // 20 + 12 = 32
      end
      3'b001: begin // S-TYPE: instr[31:25] : instr[11:7] => imm[11:0]
        imm_out = { {20{immed[31]}}, {immed[31:25], immed[11:7]}}; // 20 + 7 + 5 = 32
      end
      3'b010: begin // B-TYPE: imm[12|10:5|4:1|0]
        // Reassembled = { imm[12]=instr[31], imm[11]=instr[7], imm[10:5]=instr[30:25]
        //                 imm[4:1]=instr[11:8], imm[0]=0}
        imm_out = { {19{immed[31]}}, {immed[31], immed[7], immed[30:25], immed[11:8], 1'b0}};
      end
      3'b011: begin // U-TYPE: top 20 bits << 12, no sign extend
        imm_out = { immed[31:12], 12'b0 };
      end
      3'b100: begin // J-TYPE: imm[20|10:1|11|19:12|0]
        // Reassmbled = { imm[20]=instr[31], imm[19:12]=instr[19:12], imm[11]=instr[20]
        //                imm[10:1]=instr[30:21], imm[0]=0}
        imm_out = { {11{immed[31]}}, {immed[31], immed[19:12], immed[20], immed[30:21], 1'b0}};
      end
      default:
        imm_out = 32'b0;
    endcase
  end

  assign imm_ext = imm_out;


endmodule
