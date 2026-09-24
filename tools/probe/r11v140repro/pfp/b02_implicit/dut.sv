// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter int X = 7;
endpackage
module cc import p::*; #(parameter P = X) (output int o);
  assign o = P;
endmodule
module top(output int o); cc u(.o(o)); endmodule
