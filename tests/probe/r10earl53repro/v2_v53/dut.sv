// r10earl53 VERIFIER arm v2 — the NAME-COLLISION attack on the root map, plus
// the vpiExpr/Root_value EXTRA axis and deeper hierarchy contexts.
package pv2_v53;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sb_t;   // SAME member names, DIFFERENT width
  typedef struct packed { logic [1:0] e0; logic [1:0] e1; } el_t;
endpackage

module sinkv2_v53 #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule

module holder_v53 (output pv2_v53::sb_t s);
  assign s = '0;
endmodule

module deep_v53 (input pv2_v53::sa_t s_i, output logic [2:0] z);
  logic [2:0] n;
  // a member path at DEPTH 2 of the instance tree
  sinkv2_v53 #(.W(3)) u_d2 (.d(s_i.a), .q(n));
  assign z = n;
endmodule

module v2_v53 (
  input  pv2_v53::sa_t  s,          // LOCAL name `s`
  input  pv2_v53::sa_t  t,
  output logic [63:0]   z_o
);
  logic [2:0] n_mix, n_deep, n_var, n_net, n_both;
  logic [3:0] n_h;
  pv2_v53::sa_t sv;                 // local VAR root
  wire pv2_v53::sa_t sn;            // local NET root
  assign sv = s;
  assign sn = t;

  holder_v53 u_h ();                // u_h.s is an sb_t named `s` -- COLLIDES by NAME

  // A concat mixing the LOCAL `s.a` with the HIERARCHICAL `u_h.s.a`.
  // The root token of the second path is `u_h`, so the map must not be
  // confused; but both slang symbols are named `s`.
  sinkv2_v53 #(.W(7)) u_mix (.d({s.a, u_h.s.a}), .q({n_mix, n_h}));

  // local VAR root and local NET root in ONE concat
  sinkv2_v53 #(.W(6)) u_both (.d({sv.a, sn.b}), .q({n_both, n_var}));

  // depth-2 instance tree
  deep_v53 u_deep (.s_i(s), .z(n_deep));

  // the SAME paths in every NON-connection context (controls)
  logic [2:0] c_ca, c_pr, c_if;
  assign c_ca = s.a;
  always_comb c_pr = s.b;
  always_comb if (s.a[0]) c_if = t.b; else c_if = 3'b0;

  assign z_o = {n_mix, n_h, n_deep, n_var, n_net, n_both, c_ca, c_pr, c_if, 40'b0};
endmodule
