// § pkgRefFoldClonesMultiDimOnly140
package aes_pkg;
   parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc #(parameter logic [7:0][3:0] P = aes_pkg::X, parameter logic Z = 0) ();
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
