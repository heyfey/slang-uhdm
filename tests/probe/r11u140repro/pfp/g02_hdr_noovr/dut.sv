// § pkgRefFoldClonesMultiDimOnly140
package aes_pkg;
   parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import aes_pkg::*; #(parameter logic [7:0][3:0] P = X) ();
endmodule
module top;
  cc u();
endmodule
