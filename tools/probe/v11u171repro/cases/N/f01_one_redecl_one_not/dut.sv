// § splitPortTsKeyOnPortDecl171
module sub (clk, a, x, y);
   input clk;
   input [3:0] a;
   output x;
   output y;
   reg x;
   assign y = a[1];
   always @(posedge clk) x <= a[0];
endmodule
module dut (input clk, input [3:0] a, output x, y);
  sub u0 (clk, a, x, y);
endmodule
