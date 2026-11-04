// § pkgRefFoldClonesMultiDimOnly140
package ap;
  parameter integer X = 9;
endpackage
module cc #(parameter logic Z = 0) ();
  import ap::*;
  parameter integer P = X;
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
