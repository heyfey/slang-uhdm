// § defOnlyAliasVarNoNetType440
package p; typedef logic [3:0] v_t; typedef struct packed { logic a; } s_t; endpackage
module m #(parameter w = 2) (input clk);
  import p::*;
  typedef logic [3:0] t;
  typedef enum logic [1:0] {A, B} e_t;
  typedef t tt;
  t z; v_t v; s_t s; e_t e; tt x;
  wire t wz;
  logic [w-1:0] y;
  reg r;
  logic l;
endmodule
module top; m u(.clk(1'b0)); endmodule
