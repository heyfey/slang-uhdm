// § impPaLhsDisjointClone133
package p; parameter int X = 4; endpackage
import p::*;
module m #(parameter int Q = X) (output int o);
  assign o = Q;
endmodule
module top(output int o); m u(.o(o)); endmodule
