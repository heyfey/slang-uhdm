// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
   typedef tx_e tx_t;
endpackage
module top(output logic [3:0] o);
  lp::tx_e [0:0] w;
  assign w[0] = lp::On;
  assign o = w[0];
endmodule
