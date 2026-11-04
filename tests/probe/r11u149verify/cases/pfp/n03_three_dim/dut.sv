// § pkgRefFoldClonesMultiDimOnly140
package ap;
  parameter logic [1:0][1:0][3:0] X = 16'h1234;
endpackage
module cc import ap::*; #(parameter logic [1:0][1:0][3:0] P = X, parameter logic Z = 0) ();
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
