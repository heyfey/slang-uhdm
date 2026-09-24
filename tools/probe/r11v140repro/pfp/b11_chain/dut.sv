// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter int Y = 3;
  parameter int X = Y + 1;
endpackage
module cc import p::*; #(parameter int P = X) (output int o);
  assign o = P;
endmodule
module top(output int o); cc u(.o(o)); endmodule
