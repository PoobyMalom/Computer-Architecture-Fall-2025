module controller (
  input logic         clk,
  input logic  [6:0]  op,
  input logic  [2:0]  funct3,
  input logic  [6:0]  funct7,
  input logic         zero,
  output logic        pc_write,
  output logic        reg_write,
  output logic        mem_write,
  output logic        ir_write,
  output logic  [1:0] result_src,
  output logic  [1:0] alu_src_a,
  output logic  [1:0] alu_src_b,
  output logic        adr_src,
  output logic  [3:0] alu_ctrl,
  output logic  [2:0] imm_src,
  output logic  [2:0] branch_con
);

  localparam RESET         = 5'd13;
  localparam FETCH         = 5'd0;
  localparam DECODE        = 5'd1;
  localparam MEMADR        = 5'd2;
  localparam EXECUTER      = 5'd6; 
  localparam EXECUTEI      = 5'd8;
  localparam JAL           = 5'd9;
  localparam JALR          = 5'd14;
  localparam BRANCH        = 5'd17;
  localparam BEQ           = 5'd18;
  localparam BNE           = 5'd19;
  localparam BLT           = 5'd20;
  localparam BGE           = 5'd21;
  localparam BLTU          = 5'd16;
  localparam BGEU          = 5'd22;
  localparam BRANCH_TARGET = 5'd15;
  localparam LUI           = 5'd11;
  localparam AUIPC         = 5'd12;
  localparam MEMREAD       = 5'd3;
  localparam MEMWRITE      = 5'd5;
  localparam ALUWB         = 5'd7;
  localparam MEMWB         = 5'd4;

  logic [4:0] state;
  logic [4:0] next_state;

  logic [1:0] alu_op;

  logic branch;
  logic pc_update;

  initial begin
    state = RESET;
  end

  always_comb begin
    pc_write = (pc_update) || (branch && zero);
  end

  always_ff @(posedge clk) begin
    state <= next_state;
  end

  always_comb begin
    unique case (op)
      7'b0010011: imm_src = 3'b000;
      7'b0000011: imm_src = 3'b000;
      7'b1110011: imm_src = 3'b000;
      7'b0100011: imm_src = 3'b001;
      7'b1100011: imm_src = 3'b010;
      7'b0110111: imm_src = 3'b011;
      7'b0010111: imm_src = 3'b011;
      7'b1101111: imm_src = 3'b100;
      default: imm_src = 3'b000;
    endcase
  end

  always_comb begin
    next_state = 5'bx;
    unique case (state)
      RESET: begin
        next_state = FETCH;
      end
      FETCH: begin
        branch     = 1'b0;
        pc_update  = 1'b1;
        adr_src    = 1'b0;
        mem_write  = 1'b0;
        ir_write   = 1'b1;
        reg_write  = 1'b0;
        alu_src_a  = 2'b00;
        alu_src_b  = 2'b10;
        result_src = 2'b10;
        alu_op     = 2'b00;
        next_state = DECODE;
        branch_con = 3'bxxx;
      end
      DECODE: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b01;
        alu_src_b  = 2'b01;
        result_src = 2'b10;
        alu_op     = 2'b00;
        if (op == 7'b0000011 || op == 7'b0100011) begin
          next_state = MEMADR;
        end
        if (op == 7'b0110011) begin
          next_state = EXECUTER;
        end
        if (op == 7'b0010011 || op == 7'b0110111 || op == 7'b0010111) begin
          next_state = EXECUTEI;
        end
        if (op == 7'b1101111) begin
          next_state = JAL;
        end
        if (op == 7'b1100111) begin
          next_state = MEMADR;
        end
        if (op == 7'b1100011) begin
          unique case (funct3) 
            3'b000: next_state = BEQ;
            3'b001: next_state = BNE;
            3'b100: next_state = BLT;
            3'b101: next_state = BGE;
            3'b110: next_state = BLTU;
            3'b111: next_state = BGEU;
          endcase
        end
        if (op == 7'b0110111) begin
          next_state = LUI;
        end
        if (op == 7'b0010111) begin
          next_state = AUIPC;
        end
      end
      MEMADR: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b01;
        result_src = 2'bxx;
        alu_op     = 2'b00;
        if (op == 7'b0000011) begin
          next_state = MEMREAD;
        end
        if (op == 7'b0100011) begin
          next_state = MEMWRITE;
        end
        if (op == 7'b1100111) begin
          next_state = JALR;
        end
      end
      EXECUTER: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b00;
        result_src = 2'bxx;
        alu_op     = 2'b10;
        next_state = ALUWB;
      end
      EXECUTEI: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b01;
        result_src = 2'bxx;
        alu_op     = 2'b10;
        next_state = ALUWB;
      end
      JAL: begin
        pc_update  = 1'b1;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b01;
        alu_src_b  = 2'b10;
        result_src = 2'b00;
        alu_op     = 2'b00;
        next_state = ALUWB;
      end
      JALR: begin
        pc_update  = 1'b1;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b01;
        alu_src_b  = 2'b10;
        result_src = 2'b00;
        alu_op     = 2'b00;
        next_state = ALUWB;
      end
      BEQ: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b00;
        result_src = 2'b00;
        alu_op     = 2'b11;
        branch     = 1;
        branch_con = 3'b000;
        next_state = BRANCH_TARGET;
      end
      BNE: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b00;
        result_src = 2'b00;
        alu_op     = 2'b11;
        branch     = 1;
        branch_con = 3'b001;
        next_state = BRANCH_TARGET;
      end
      BLT: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b00;
        result_src = 2'b00;
        alu_op     = 2'b11;
        branch     = 1;
        branch_con = 3'b010;
        next_state = BRANCH_TARGET;
      end
      BGE: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b00;
        result_src = 2'b00;
        alu_op     = 2'b11;
        branch     = 1;
        branch_con = 3'b011;
        next_state = BRANCH_TARGET;
      end
      BLTU: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b00;
        result_src = 2'b00;
        alu_op     = 2'b11;
        branch     = 1;
        branch_con = 3'b100;
        next_state = BRANCH_TARGET;
      end
      BGEU: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b00;
        result_src = 2'b00;
        alu_op     = 2'b11;
        branch     = 1;
        branch_con = 3'b101;
        next_state = BRANCH_TARGET;
      end
      BRANCH_TARGET: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b01;
        alu_src_b  = 2'b01;
        result_src = 2'b00;
        alu_op     = 2'b00;
        branch     = 1;
        branch_con = 3'bxxx;
        next_state = FETCH;
      end
      LUI: begin
        pc_update  = 1'b0;
        adr_src    = 1'b0;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b01; 
        result_src = 2'b01;
        alu_op     = 2'b00;
        next_state = ALUWB;
      end
      AUIPC: begin
        pc_update  = 1'b0;
        adr_src    = 1'b0;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b01;
        alu_src_b  = 2'b01; 
        result_src = 2'b01;
        alu_op     = 2'b00;
        next_state = ALUWB;
      end
      MEMREAD: begin
        pc_update  = 1'b0;
        adr_src    = 1'b1;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b01;
        result_src = 2'b00;
        alu_op     = 2'bxx;
        next_state = MEMWB;
      end
      MEMWRITE: begin
        pc_update  = 1'b0;
        adr_src    = 1'b1;
        mem_write  = 1'b1;
        ir_write   = 1'b0;
        reg_write  = 1'b0;
        alu_src_a  = 2'bxx;
        alu_src_b  = 2'bxx;
        result_src = 2'b00;
        alu_op     = 2'bxx;
        next_state = FETCH;
      end
      ALUWB: begin
        pc_update  = 1'b0;
        adr_src    = 1'bx;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b1;
        alu_src_a  = 2'bxx;
        alu_src_b  = 2'bxx;
        result_src = 2'b00;
        alu_op     = 2'bxx;
        next_state = FETCH;
      end
      MEMWB: begin
        pc_update  = 1'b0;
        adr_src    = 1'b1;
        mem_write  = 1'b0;
        ir_write   = 1'b0;
        reg_write  = 1'b1;
        alu_src_a  = 2'b10;
        alu_src_b  = 2'b01;
        result_src = 2'b01;
        alu_op     = 2'bxx;
        next_state = FETCH;
      end
    endcase
  end

  alu_decoder decode (
    .funct3       (funct3),
    .funct7       (funct7),
    .alu_op       (alu_op),
    .alu_ctrl     (alu_ctrl)
  );

endmodule
