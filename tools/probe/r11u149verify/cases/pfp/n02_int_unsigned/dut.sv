// § pkgRefFoldClonesMultiDimOnly140
package ap;
  parameter int unsigned X = 40;
endpackage
module cc import ap::*; #(parameter int unsigned P = X) ();
endmodule
module top;
  cc u();
endmodule
