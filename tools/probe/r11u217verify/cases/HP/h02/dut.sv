// § pkgArrTdElemClone209 — r11u217 h02: package array typedefs whose element struct has a nested struct member, and a union element; read in one module
package q;
  typedef struct packed { logic [1:0] u; logic v; } in_t;
  typedef struct packed { in_t n; logic x; } s_t;
  typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
  typedef s_t [1:0] a_t;
  typedef u_t [1:0] c_t;
endpackage
module top (output logic o, output logic [1:0] p, output logic [3:0] r);
  q::a_t w;
  q::c_t c;
  assign w = '0;
  assign c = '0;
  assign o = w[1].x;
  assign p = w[0].n.u;
  assign r = c[1].b;
endmodule
