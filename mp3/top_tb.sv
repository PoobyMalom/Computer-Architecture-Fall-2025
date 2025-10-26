`timescale 10ns/10ns
`include "top.sv"

module top_tb;

  logic clk = 0;
  logic _45a;
  logic _48b;

  top u0 (
    .clk        (clk),
    ._45a       (_45a),
    ._48b       (_48b)
  );

  initial begin
    $dumpfile("top.vcd");
    $dumpvars(0, top_tb);
    #100000000
    $finish;
  end

  always begin
    #4
    clk = ~clk;
  end

endmodule