// § impPaLhsDisjointClone133
package p; parameter int X = 4; endpackage
module m (output int o);
  import p::*;
  parameter int Q = X;
  assign o = Q;
endmodule
module top(output int o); m u(.o(o)); endmodule
