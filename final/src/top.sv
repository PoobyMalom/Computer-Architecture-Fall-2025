// `include "memory.sv"
// `include "ir.sv"
// `include "imm_extend.sv"
// `include "reg_file.sv"
// `include "alu.sv"
// `include "controller.sv"

`timescale 1ns / 10ps

module top (
    input logic clk
);

    logic [31:0] address;

    logic [31:0] dmem_data_in;
    logic [31:0] dmem_data_out;

    logic [31:0] program_counter;

    logic [31:0] imem_data_out;

    logic pc_write;
    logic [31:0] result_data;

    initial begin 
        program_counter = 32'h1000;
    end

    always_ff @(posedge clk) begin
        if (pc_write) begin
            program_counter <= result_data;
        end
    end

    logic [6:0] op;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic reg_write;
    logic mem_write;
    logic ir_write;
    
    logic [1:0] result_src;
    logic [1:0] alu_src_a;
    logic [1:0] alu_src_b;
    logic       adr_src;
    logic [4:0] alu_ctrl;
    logic [2:0] imm_src;
    logic [2:0] branch_con;
    logic       zero;



    controller CNTRL (
        .clk            (clk),
        .op             (op),
        .funct3         (funct3),
        .funct7         (funct7),
        .zero           (zero),
        .pc_write       (pc_write),
        .reg_write      (reg_write),
        .mem_write      (mem_write),
        .ir_write       (ir_write),
        .result_src     (result_src),
        .alu_src_a      (alu_src_a),
        .alu_src_b      (alu_src_b),
        .adr_src        (adr_src),
        .alu_ctrl       (alu_ctrl),
        .imm_src        (imm_src),
        .branch_con     (branch_con)
    );

    logic [31:0] alu_out;

    logic [31:0] instr_reg;
    logic [31:0] old_pc;

    always_comb begin
        if (ir_write) begin
            instr_reg = imem_data_out;
        end
    end

    always_ff @(posedge clk) begin
        if (ir_write) begin
            // instr_reg = imem_data_out;
            old_pc <= program_counter;
        end
    end

    always_comb begin
        op     = instr_reg[6:0];
        funct3 = instr_reg[14:12];
        funct7 = instr_reg[31:25];
    end

    logic [31:0] data;

    always_ff @(negedge clk) begin
        data <= dmem_data_out;
    end

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    register_file REG (
        .clk            (clk),
        .reg_write      (reg_write),
        .rs1            (instr_reg[19:15]),
        .rs2            (instr_reg[24:20]),
        .rd             (instr_reg[11:7]),
        .wd             (result_data),
        .rd1            (rs1_data),
        .rd2            (rs2_data)
    );

    logic [31:0] A_reg [1:0];

    always_ff @(posedge clk) begin
        A_reg[0] <= rs1_data;
        A_reg[1] <= rs2_data;
    end

    logic [31:0] imm_ext;

    immediate_extender EX (
        .immed          (instr_reg[31:7]),
        .imm_src        (imm_src),
        .imm_ext        (imm_ext)
    );

    logic [31:0] ALUResult;

    logic [31:0] alu_data_a;
    logic [31:0] alu_data_b;

    always_comb begin
        unique case (alu_src_a)
            2'b00: alu_data_a = program_counter;
            2'b01: alu_data_a = old_pc;
            2'b10: alu_data_a = A_reg[0];
            default: alu_data_a = A_reg[0];
        endcase
        unique case (alu_src_b)
            2'b00: alu_data_b = A_reg[1];
            2'b01: alu_data_b = imm_ext;
            2'b10: alu_data_b = 32'd4;
            default: alu_data_b = A_reg[1];
        endcase
    end

    assign dmem_data_in = A_reg[1];

    alu ALU (
        .SrcA           (alu_data_a),
        .SrcB           (alu_data_b),
        .ALUControl     (alu_ctrl),
        .Branch_Con     (branch_con),
        .ALUResult      (ALUResult),
        .zero           (zero)
    );

    always_ff @(posedge clk) begin
        alu_out <= ALUResult;
    end



    always_comb begin
        unique case (result_src)
            2'b00: result_data = alu_out;
            2'b01: result_data = data;
            2'b10: result_data = ALUResult;
            default: result_data = alu_out;
        endcase
    end

    always_comb begin
        unique case (adr_src)
            1'b0: address = program_counter;
            1'b1: address = result_data;
            default: address = program_counter;
        endcase
    end

    memory #(
        .IMEM_INIT_FILE_PREFIX  ("test-prog-2/rv32i_test")
    ) memory (
        .clk            (clk), 
        .funct3         (funct3), 
        .dmem_wren      (mem_write), 
        .dmem_address   (address), 
        .dmem_data_in   (dmem_data_in), 
        .imem_address   (program_counter), 
        .imem_data_out  (imem_data_out), 
        .dmem_data_out  (dmem_data_out)
    );



endmodule
