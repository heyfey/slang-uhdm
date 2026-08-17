// r10earl53 VERIFIER arm v1 — EXTRA-hunting: connection-actual shapes the
// implementer's a1/a2 did NOT cover, plus the per-operand ROOT DISCRIMINATION
// test (two DIFFERENT struct roots in one concat; a mis-pairing would give
// both the same typespec).
package pv1_v53;
  typedef struct packed { logic [2:0] op; logic [1:0] pr; } inner_t;
  typedef struct packed { inner_t i; logic [3:0] w; } outer_t;
  typedef struct packed { outer_t o; logic v; } top_t;
  typedef struct packed { logic [3:0] w; logic [2:0] q; } other_t;
  typedef struct packed { logic [1:0] e0; logic [1:0] e1; } el_t;
endpackage

module sinkv1_v53 #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule

module a_v53 (input pv1_v53::top_t t_i, output logic [3:0] z);
  assign z = {t_i.o.w[3:1], t_i.v};
endmodule

module v1_v53 (
  input  pv1_v53::top_t   t_i,
  input  pv1_v53::other_t o_i,
  input  pv1_v53::top_t [1:0] pa_i,      // PACKED array of typedef'd struct
  inout  wire logic [1:0] io_w,
  output logic [63:0]     z_o
);
  function automatic logic [3:0] f4(input logic [3:0] a); return a ^ 4'h5; endfunction

  logic [3:0] n_un, n_cast, n_str, n_ps, n_bs, n_fc, n_sf, n_pa;
  logic [6:0] n_two;
  logic [3:0] n_lit;
  logic [1:0] n_io;
  logic [3:0] n_hier;

  // --- operation shapes NOT in a1 ---
  sinkv1_v53 #(.W(4)) u_un   (.d(~t_i.o.w),                 .q(n_un));
  sinkv1_v53 #(.W(4)) u_cast (.d(4'(t_i.o.i.op)),           .q(n_cast));
  sinkv1_v53 #(.W(4)) u_str  (.d({<<{t_i.o.w}}),            .q(n_str));
  sinkv1_v53 #(.W(3)) u_ps   (.d(t_i.o.w[3:1]),             .q(n_ps[2:0]));
  sinkv1_v53 #(.W(1)) u_bs   (.d(t_i.o.w[2]),               .q(n_bs[0:0]));
  sinkv1_v53 #(.W(4)) u_fc   (.d(f4(t_i.o.w)),              .q(n_fc));
  sinkv1_v53 #(.W(4)) u_sf   (.d($unsigned(t_i.o.w)),       .q(n_sf));
  sinkv1_v53 #(.W(4)) u_lit  (.d({t_i.o.i.pr, 2'b01}),      .q(n_lit));

  // --- TWO DIFFERENT ROOTS in ONE concat: each path MUST take ITS OWN root ---
  sinkv1_v53 #(.W(7)) u_two  (.d({t_i.o.w, o_i.q}),         .q(n_two));

  // --- PACKED array-of-struct root ---
  sinkv1_v53 #(.W(4)) u_pa   (.d(pa_i[1].o.w),              .q(n_pa));

  // --- INOUT-direction actual containing a member path is illegal; use a
  //     plain inout plus a member path on an input in the same instance ---
  sinkv1_v53 #(.W(2)) u_io   (.d({t_i.v, io_w[0]}),         .q(n_io));

  // --- a HIERARCHICAL path (root is an instance, not a value) inside a conn ---
  a_v53 u_a (.t_i(t_i), .z());
  sinkv1_v53 #(.W(4)) u_hier (.d({u_a.z[2:0], t_i.v}),      .q(n_hier));

  assign z_o = {n_un, n_cast, n_str, n_ps, n_bs, n_fc, n_sf, n_lit,
                n_two, n_pa, n_io, n_hier, 5'b0};
endmodule
