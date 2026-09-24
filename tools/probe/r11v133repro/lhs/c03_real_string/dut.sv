// § impPaLhsDisjointClone133
package p; parameter real R = 1.5; parameter string S = "ab"; parameter int X = 3; endpackage
module m import p::*; #(parameter int Q = X) (output int o);
  assign o = Q + int'(R) + S.len();
endmodule
module top(output int o); m u(.o(o)); endmodule
