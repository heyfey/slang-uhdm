// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
endpackage
module top(output logic [3:0] o);
  typedef lp::tx_e my_t;
  my_t [0:0] w;
  assign w[0] = lp::On;
  assign o = w[0];
endmodule
