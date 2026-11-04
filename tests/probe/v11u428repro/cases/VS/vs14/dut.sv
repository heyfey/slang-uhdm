// § ndaWholeSysCallSharesLhs428
module m(input [7:0] x, output [63:0] o);
  wire [63:0] t = $time;
  assign o = t;
endmodule
module top(input [7:0] a, output [63:0] c);
  m u1(.x(a), .o(c));
endmodule
