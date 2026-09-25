// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
   typedef tx_e tx_t;
endpackage
module top(input lp::tx_t [1:0] i, output logic [3:0] o);
  assign o = i[0];
endmodule
