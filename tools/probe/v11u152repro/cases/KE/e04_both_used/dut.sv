// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
   typedef tx_e tx_t;
endpackage
module top(output logic [3:0] o);
  lp::tx_e [0:0] v;
  lp::tx_t [0:0] w;
  assign v[0] = lp::On;
  assign w[0] = lp::On;
  assign o = w[0] ^ v[0];
endmodule
