// § ndaWholeSysCallSharesLhs428
module m(input [7:0] x, output [3:0] o);
  wire [3:0] n = $countones(x);
  assign o = n;
endmodule
module top(input [7:0] a, output [3:0] c);
  m u1(.x(a), .o(c));
endmodule
