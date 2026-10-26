// § defOnlyAliasVarNoNetType440
package p; typedef struct packed { logic a; logic [1:0] b; } s_t; typedef logic [3:0] v_t; endpackage
module m (input clk);
  p::s_t s;
  p::v_t v;
  wire p::v_t wv;
endmodule
module top; endmodule
