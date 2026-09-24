// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter real X = 1.5;
endpackage
module cc import p::*; #(parameter real P = X) ();
endmodule
module top; cc u(); endmodule
