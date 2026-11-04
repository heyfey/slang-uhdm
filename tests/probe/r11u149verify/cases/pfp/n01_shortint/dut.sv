// § pkgRefFoldClonesMultiDimOnly140
package ap;
  parameter shortint X = 16'sd12;
endpackage
module cc import ap::*; #(parameter shortint P = X, parameter logic Z = 0) ();
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
