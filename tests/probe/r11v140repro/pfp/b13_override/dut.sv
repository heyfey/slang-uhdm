// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter int X = 9;
endpackage
module cc import p::*; #(parameter int P = X) (output int o);
  assign o = P;
endmodule
module top(output int o, output int o2); cc #(.P(3)) u(.o(o)); cc u2(.o(o2)); endmodule
