// § impPaLhsDisjointClone133
package p; parameter int X = 4; parameter int Y = 6; endpackage
module m import p::*; #(parameter int Q = X) (output int o);
  assign o = Q + Y;
endmodule
module top(output int o, output int o2); m u(.o(o)); m #(.Q(9)) v(.o(o2)); endmodule
