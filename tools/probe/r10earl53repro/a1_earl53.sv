// r10earl53 arm a1 — WHEN does golden hang a ref_typespec off a hier_path?
//
// The head says: a hier_path OPERAND of a CONCAT port connection carries a
// ref_typespec whose vpiActual is the BASE object's struct typespec.  This arm
// puts the same written path in EVERY context a hier_path can appear in, so
// the discriminator is measured, not assumed:
//
//   * direct member conn (one level)      -- the shape we already emit
//   * direct member conn (TWO/THREE deep) -- the 2124-row corpus family
//   * concat operand                      -- the HEAD
//   * nested concat operand
//   * replication / binary-op / ternary operand inside the conn
//   * element-select base, array-of-struct base
//   * the SAME paths in a cont_assign LHS/RHS and in an always block
//     (golden must NOT attach there -- 2 000+ corpus rows say so)
//   * a UNION base and an ANONYMOUS-struct base (typespec KIND fence)

package p1_earl53;
  typedef struct packed {
    logic [2:0] op;
    logic [1:0] pr;
  } inner_t;
  typedef struct packed {
    inner_t     i;
    logic [3:0] w;
  } outer_t;
  typedef struct packed {
    outer_t     o;
    logic       v;
  } top_t;
  typedef union packed {
    logic [4:0] a;
    logic [4:0] b;
  } uni_t;
  typedef struct packed {
    logic [1:0] e0;
    logic [1:0] e1;
  } el_t;
endpackage

module sink1_earl53 #(parameter int W = 8) (
  input  logic [W-1:0] d,
  output logic [W-1:0] q
);
  assign q = d;
endmodule

module a1_earl53 (
  input  p1_earl53::top_t  t_i,
  input  p1_earl53::uni_t  u_i,
  input  p1_earl53::el_t   ea_i [0:1],
  input  struct packed { logic [2:0] m; logic n; } anon_i,
  output logic [63:0]      z_o
);
  logic [2:0]  n_one;
  logic [2:0]  n_two;
  logic [2:0]  n_three;
  logic [4:0]  n_uni;
  logic [2:0]  n_anon;
  logic [1:0]  n_arr;
  logic [5:0]  n_cat;
  logic [8:0]  n_ncat;
  logic [5:0]  n_rep;
  logic [2:0]  n_bin;
  logic [2:0]  n_ter;
  logic [2:0]  n_ca;
  logic [2:0]  n_pr;

  // ---- DIRECT member connections, 1 / 2 / 3 levels deep ----
  sink1_earl53 #(.W(1)) u_one   (.d(t_i.v),         .q(n_one[0:0]));
  sink1_earl53 #(.W(4)) u_two   (.d(t_i.o.w),       .q(n_two[2:0]));
  sink1_earl53 #(.W(3)) u_three (.d(t_i.o.i.op),    .q(n_three));

  // ---- other BASE kinds ----
  sink1_earl53 #(.W(5)) u_uni   (.d(u_i.a),         .q(n_uni));
  sink1_earl53 #(.W(3)) u_anon  (.d(anon_i.m),      .q(n_anon));
  sink1_earl53 #(.W(2)) u_arr   (.d(ea_i[1].e0),    .q(n_arr));

  // ---- THE HEAD: concat / nested concat operands ----
  sink1_earl53 #(.W(6)) u_cat   (.d({t_i.o.i.op, t_i.o.i.pr, t_i.v}), .q(n_cat));
  sink1_earl53 #(.W(9)) u_ncat  (.d({t_i.o.w, {t_i.o.i.op, t_i.v, t_i.o.i.pr}}),
                                 .q(n_ncat));

  // ---- other OPERATION shapes inside a connection ----
  sink1_earl53 #(.W(6)) u_rep   (.d({2{t_i.o.i.op}}),                 .q(n_rep));
  sink1_earl53 #(.W(3)) u_bin   (.d(t_i.o.i.op & t_i.o.i.op),         .q(n_bin));
  sink1_earl53 #(.W(3)) u_ter   (.d(t_i.v ? t_i.o.i.op : 3'b0),       .q(n_ter));

  // ---- the SAME paths OUTSIDE a connection: golden must NOT attach ----
  assign n_ca = t_i.o.i.op;
  always_comb n_pr = t_i.o.i.op;
  assign z_o = {n_one, n_two, n_three, n_uni, n_anon, n_arr, n_cat, n_ncat,
                n_rep, n_bin, n_ter, n_ca, n_pr, t_i.o.i.op};
endmodule
