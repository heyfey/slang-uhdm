// § packedElemAliasTypedef152
package lp;
   typedef struct packed { logic [3:0] a; } s_t;
   typedef s_t a_t;
endpackage
module top(output logic [3:0] o);
  lp::a_t [1:0] w;
  assign w = '0;
  assign o = w[0].a;
endmodule
