// § impPaLhsDisjointClone133
package p; parameter X = 48; endpackage
module m import p::*; #(parameter Q = X) (output int o);
  assign o = Q;
endmodule
module top(output int o); m u(.o(o)); endmodule
