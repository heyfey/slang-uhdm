// § impPaLhsDisjointClone133
package p; parameter int N = 3; parameter int A [N-1:0] = '{1, 2, 3}; endpackage
module m import p::*; #(parameter int Q = N) (output int o);
  assign o = A[0] + Q;
endmodule
module top(output int o); m u(.o(o)); endmodule
