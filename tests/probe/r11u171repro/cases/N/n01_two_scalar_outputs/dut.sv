// § splitPortTsKeyOnPortDecl171
module sub (clk, a, b, x, y);
   input		clk;
   input [3:0] 	a, b;
   output		x;
   output		y;
   assign x = a[0];
   assign y = b[0];
endmodule
module dut (input clk, input [3:0] a, b, output x, y);
  sub u0 (clk, a, b, x, y);
endmodule
