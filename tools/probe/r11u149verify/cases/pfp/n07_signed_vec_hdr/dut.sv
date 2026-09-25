// § pkgRefFoldClonesMultiDimOnly140
package ap;
  parameter logic signed [15:0] X = 16'sd5;
endpackage
module cc import ap::*; #(parameter logic signed [15:0] P = X, parameter logic Z = 0) ();
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
