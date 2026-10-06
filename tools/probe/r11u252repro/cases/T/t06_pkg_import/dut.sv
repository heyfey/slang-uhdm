// § lazyTernArithLeftSpan252
package p;
  localparam X = 2;
  localparam Y = 1;
endpackage
module top import p::*; #(parameter Z = 1, localparam T = 0,
  localparam int A[2:0] = T ? '{X+Y, Y, 0} : '{Y-X+4, X, 0}) ();
endmodule
