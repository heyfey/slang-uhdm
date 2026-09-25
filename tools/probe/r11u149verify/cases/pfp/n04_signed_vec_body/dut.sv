// § pkgRefFoldClonesMultiDimOnly140
package ap;
  parameter logic signed [15:0] X = -16'sd5;
endpackage
module cc #(parameter logic Z = 0) ();
  import ap::*;
  parameter logic signed [15:0] P = X;
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
