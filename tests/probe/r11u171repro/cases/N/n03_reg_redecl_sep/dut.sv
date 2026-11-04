// § splitPortTsKeyOnPortDecl171
module sub (clk, a, x, y);
   input		clk;
   input [3:0] 	a;
   output		x;
   output		y;
   reg 			x;
   reg 			y;
   always @(posedge clk) begin x <= a[0]; y <= a[1]; end
endmodule
module dut (input clk, input [3:0] a, output x, y);
  sub u0 (clk, a, x, y);
endmodule
