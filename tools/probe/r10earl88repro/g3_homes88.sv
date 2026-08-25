// r10earl88 g3 — HOMES: the same two element structs in an INTERFACE, a
// PROGRAM, a GENERATE scope, and a THREE-DEEP instance chain, each leaf
// instantiated more than once.  The law is written at the module-instance
// signal site, so every other home is a NEGATIVE CONTROL: nothing there may
// move.  MEASUREMENT ONLY.
package r88;
  typedef struct packed { logic a; logic [3:0] b; } f_t;               // STRICT 1
  typedef struct packed { struct packed { logic q; } e; logic c; } n_t;  // STRICT 0
endpackage

interface if88 (input logic clk);
  r88::f_t [1:0] if_body_f;          // interface BODY declarations
  r88::n_t [1:0] if_body_n;
  modport mp (input if_body_f, if_body_n);
endinterface

program pg88 (input r88::n_t [1:0] pg_in_n);
  r88::n_t [1:0] pg_body_n;
endprogram

module deep3 (input r88::f_t [1:0] d3_f, input r88::n_t [1:0] d3_n);
  r88::n_t [1:0] d3_body_n;
endmodule

module deep2 (input r88::f_t [1:0] d2_f, input r88::n_t [1:0] d2_n);
  deep3 u_a (.d3_f(d2_f), .d3_n(d2_n));
  deep3 u_b (.d3_f(d2_f), .d3_n(d2_n));
endmodule

module deep1 (input r88::f_t [1:0] d1_f, input r88::n_t [1:0] d1_n);
  deep2 u_c (.d2_f(d1_f), .d2_n(d1_n));
endmodule

module gsc88 (input r88::f_t [1:0] g_f, input r88::n_t [1:0] g_n);
  for (genvar gi = 0; gi < 2; gi++) begin : gb
    r88::f_t [1:0] gs_f;             // GEN-SCOPE body declarations
    r88::n_t [1:0] gs_n;
    assign gs_f = g_f;
    assign gs_n = g_n;
    deep3 u_g (.d3_f(gs_f), .d3_n(gs_n));
  end
  if (1) begin : gi88
    r88::n_t [1:0] gi_n;
    assign gi_n = g_n;
  end
endmodule

module top88 (input logic clk);
  r88::f_t [1:0] tf; r88::n_t [1:0] tn;
  if88 u_if (.clk(clk));
  pg88 u_pg (.pg_in_n(tn));
  deep1 u_d1 (.d1_f(tf), .d1_n(tn));
  deep1 u_d1b (.d1_f(tf), .d1_n(tn));
  gsc88 u_gs (.g_f(tf), .g_n(tn));
endmodule
