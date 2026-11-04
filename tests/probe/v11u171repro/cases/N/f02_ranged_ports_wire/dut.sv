// § splitPortTsKeyOnPortDecl171
module sub (a, b, y);
   input [3:0] a;
   input [3:0] b;
   output [3:0] y;
   wire [3:0] a, b;
   reg [3:0] y;
   always @* y = a ^ b;
endmodule
module dut (input [3:0] a, b, output [3:0] y);
  sub u0 (a, b, y);
endmodule
