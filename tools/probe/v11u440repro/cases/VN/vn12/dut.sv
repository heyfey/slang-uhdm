// § defOnlyAliasVarNoNetType440
package p; typedef enum logic [1:0] {A, B} e_t; typedef logic [3:0] v_t; endpackage
module m (input clk);
  import p::v_t;
  v_t a;
  wire v_t b;
  p::e_t e;
endmodule
module top; endmodule
