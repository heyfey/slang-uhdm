// § pkgPatArithLeftParenSpan236 — operands spanning lines and a macro-conditional operand
package pk;
  localparam int N = 3;
  typedef struct packed { integer unsigned a; integer unsigned b; } d_s;
  typedef struct packed { integer unsigned a; integer unsigned b; integer unsigned c; } cfg_s;
  localparam d_s q = '{a: 2, b: 5};
  localparam cfg_s p0 = '{a: (N -
              1) * 2, b: (1 << 2)
                 | (1 << 0), c: (`ifdef X 1 `else 2 `endif) + 1};
endpackage
module top (output int o);
  assign o = 1;
endmodule
