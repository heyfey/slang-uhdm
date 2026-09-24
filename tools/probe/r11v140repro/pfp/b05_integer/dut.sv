// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter integer X = 12;
endpackage
module cc import p::*; #(parameter integer P = X) (output integer o);
  assign o = P;
endmodule
module top(output integer o); cc u(.o(o)); endmodule
