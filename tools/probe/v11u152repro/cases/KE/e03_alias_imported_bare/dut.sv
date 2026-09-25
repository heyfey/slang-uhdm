// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
   typedef tx_e tx_t;
endpackage
module top import lp::*; (output logic [3:0] o);
  tx_t [0:0] w;
  assign w[0] = On;
  assign o = w[0];
endmodule
