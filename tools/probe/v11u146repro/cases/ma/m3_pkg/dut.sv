// § modArrayBoundRefArrayPath146
package p; parameter N = 2; endpackage
module sub(input i, output o); assign o = i; endmodule
module top(input [1:0] a, output [1:0] b);
  sub u[p::N-1:0] (.i(a), .o(b));
endmodule
