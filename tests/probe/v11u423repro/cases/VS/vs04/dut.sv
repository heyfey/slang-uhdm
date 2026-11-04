// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'd9;
endpackage
module sub #(parameter int P = 1) (output int o);
  assign o = P;
endmodule
module top(output int y);
  import p::*;
  sub #(.P(H)) u(.o(y));
endmodule
