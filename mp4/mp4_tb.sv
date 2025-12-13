`timescale 1ns / 10ps
//`include "top.sv"

module mp4_tb;

    logic clk = 0;


    top u0 (
        .clk            (clk)
    );

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, mp4_tb);
        #10000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

