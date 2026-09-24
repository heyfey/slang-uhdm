// § impPaLhsDisjointClone133
package p; parameter int X = 4; endpackage
module m import p::*; #(parameter int Q = X) (output int o);
  assign o = Q + X;
endmodule
module top(output int o1, output int o2);
  m u1(.o(o1));
  m #(.Q(7)) u2(.o(o2));
endmodule
