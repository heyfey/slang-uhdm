// § impPaLhsDisjointClone133
package p; parameter int X = 4; endpackage
module m import p::*; (output int o);
  assign o = X;
endmodule
module top(output int o); m u(.o(o)); endmodule
