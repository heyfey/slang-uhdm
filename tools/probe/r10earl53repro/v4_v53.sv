// r10earl53 VERIFIER arm v4 — package-scoped roots, enum roots, ternary with
// TWO distinct struct roots, deep operation nesting, and the SAME written path
// used by two different connections.
package pv4_v53;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [2:0] op; logic [1:0] pr; } inner_t;
  typedef struct packed { inner_t i; logic [3:0] w; } outer_t;
  typedef struct packed { logic [3:0] w; logic [2:0] q; } other_t;
  typedef struct packed { e_t e; logic [1:0] k; } withenum_t;
  outer_t gvar;                       // PACKAGE-SCOPED struct variable
endpackage

module sinkv4_v53 #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule

module v4_v53 (
  input  pv4_v53::outer_t     o_i,
  input  pv4_v53::other_t     r_i,
  input  pv4_v53::withenum_t  we_i,
  input  logic                sel,
  output logic [63:0]         z_o
);
  logic [3:0] n_pkg, n_ter, n_deep, n_sh1, n_sh2;
  logic [1:0] n_en;

  // PACKAGE-scoped struct variable as the ROOT
  sinkv4_v53 #(.W(4)) u_pkg (.d(pv4_v53::gvar.w),            .q(n_pkg));
  // ENUM member of a struct root
  sinkv4_v53 #(.W(2)) u_en  (.d(we_i.e),                     .q(n_en));
  // TERNARY with TWO DIFFERENT struct roots in the two arms
  sinkv4_v53 #(.W(4)) u_ter (.d(sel ? o_i.w : r_i.w),        .q(n_ter));
  // DEEP nesting: replication of a concat of a binary of a ternary
  sinkv4_v53 #(.W(4)) u_deep(.d({2{{(sel ? o_i.i.pr : r_i.q[1:0]) & 2'b11}}}), .q(n_deep));
  // the SAME written path in TWO different connections
  sinkv4_v53 #(.W(4)) u_sh1 (.d(o_i.w),                      .q(n_sh1));
  sinkv4_v53 #(.W(4)) u_sh2 (.d(o_i.w),                      .q(n_sh2));

  assign z_o = {n_pkg, n_en, n_ter, n_deep, n_sh1, n_sh2, 42'b0};
endmodule
