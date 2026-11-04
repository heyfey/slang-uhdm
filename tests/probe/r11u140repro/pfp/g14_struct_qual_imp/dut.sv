// § pkgRefFoldClonesMultiDimOnly140
package aes_pkg;
   parameter logic [7:0][3:0] X = 32'habcd;
   parameter int XI = 5;
   typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
   localparam s_t D = 16'hbeef;
endpackage
module cc import aes_pkg::*; #(parameter s_t P = aes_pkg::D) ();
endmodule
module top;
  cc u();
endmodule
