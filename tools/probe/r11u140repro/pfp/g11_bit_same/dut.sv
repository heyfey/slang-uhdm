// § pkgRefFoldClonesMultiDimOnly140
package aes_pkg;
   parameter logic [7:0][3:0] X = 32'habcd;
   parameter int XI = 5;
   typedef logic [7:0][3:0] w_t;
endpackage
module cc import aes_pkg::*; #(parameter bit [7:0][3:0] P = X) ();
endmodule
module top;
  cc u();
endmodule
