module register_file (
  input logic         clk,
  input logic         reg_write, // Write to register flag
  input logic  [4:0]  rs1, // Register Source 1
  input logic  [4:0]  rs2, // Register Source 2
  input logic  [4:0]  rd,  // Register Destination
  input logic  [31:0] wd,  // Write Data (From Output ALU to Register File)
  output logic [31:0] rd1, // Output Register 1
  output logic [31:0] rd2  // Output Register 2
);

  
  logic [31:0] regs [32];

  initial begin
    for (int i = 0; i < 32; i++) begin
      regs[i] = 32'b0;
    end
  end

  assign rd1 = (rs1 == 0) ? 32'b0 : regs[rs1];
  assign rd2 = (rs2 == 0) ? 32'b0 : regs[rs2];

  always_ff @(posedge clk) begin
    if (reg_write && (rd != 0)) begin
      regs[rd] <= wd;
    end
  end 

endmodule
