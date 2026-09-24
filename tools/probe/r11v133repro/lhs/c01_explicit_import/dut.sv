// § impPaLhsDisjointClone133
package p; parameter int X = 4; parameter int Y = 5; endpackage
module m import p::X; #(parameter int Q = X) (output int o);
  assign o = Q;
endmodule
module top(output int o); m u(.o(o)); endmodule
