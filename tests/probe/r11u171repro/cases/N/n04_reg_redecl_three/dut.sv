// § splitPortTsKeyOnPortDecl171
module sub (clk, a, x, y, z);
   input		clk;
   input [3:0] 	a;
   output		x;
   output		y;
   output		z;
   reg 			x, y, z;
   always @(posedge clk) begin x <= a[0]; y <= a[1]; z <= a[2]; end
endmodule
module dut (input clk, input [3:0] a, output x, y, z);
  sub u0 (clk, a, x, y, z);
endmodule
