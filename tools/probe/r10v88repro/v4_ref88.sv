// r10v88 v4 — ADVERSARIAL: `ref` ports.  MEASUREMENT ONLY.
package u88;
  typedef struct packed { logic a; logic [3:0] b; }        f_t;
  typedef struct packed { struct packed { logic q; } e; logic c; } n_t;
endpackage
module vrefleaf (ref u88::f_t [1:0] r_f, ref u88::n_t [1:0] r_n);
endmodule
module vtop4;
  u88::f_t [1:0] w_f;  u88::n_t [1:0] w_n;
  vrefleaf u_r (.r_f(w_f), .r_n(w_n));
endmodule
