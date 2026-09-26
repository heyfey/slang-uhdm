// § splitPortTsKeyOnPortDecl171
module sub (clk, a, x, y);
   input clk;
   input [7:0] a;
   output [3:0] x;
   output [3:0] y;
   reg [3:0] x, y;
   always @(posedge clk) begin x <= a[3:0]; y <= a[7:4]; end
endmodule
module dut (input clk, input [7:0] a, output [3:0] x, y);
  sub u0 (clk, a, x, y);
  sub u1 (clk, ~a, , );
endmodule
