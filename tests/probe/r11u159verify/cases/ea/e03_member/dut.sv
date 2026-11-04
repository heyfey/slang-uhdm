// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
   typedef tx_e tx_t;
endpackage
module top(output logic [7:0] o);
  typedef struct packed { lp::tx_t [1:0] f; } s_t;
  s_t v;
  assign v.f = {lp::On, lp::On};
  assign o = v;
endmodule
