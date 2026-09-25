// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
endpackage
package lq;
   typedef lp::tx_e my_t;
endpackage
module top(output logic [3:0] o);
  import lq::*;
  my_t [1:0] w;
  assign w = {lp::On, lp::On};
  assign o = w[1];
endmodule
