// r10earl53 arm a2 — the BLAST RADIUS of § connPathRootTs53.
//
// a1 established that a port-connection hier_path takes a ref_typespec for its
// ROOT object's typespec (struct AND union), that a 3-level path and every
// operation shape take it, and that an ARRAY root takes NONE.  a2 asks where
// the rule must NOT fire, and which roots are which:
//
//   * PACKED array-of-struct root, UNPACKED array-of-struct root (typedef'd
//     array type -- the fence's real target)
//   * a MID-PATH select (`s.arr[1].e0`) -- Earlgrey's `hw2reg.configin[0].pend.d`
//   * OUTPUT-direction connection, INOUT
//   * an instance in a GENERATE scope and in a generate FOR
//   * an INTERFACE member connection (the § iface_member_port fence's territory)
//   * a hier_path reached through the enclosing module's OWN struct PORT vs a
//     local struct VAR vs a local struct NET
//   * an instance ARRAY
//   * a path used in BOTH a conn and a cont_assign in the same module

package p2_earl53;
  typedef struct packed {
    logic [1:0] e0;
    logic [1:0] e1;
  } el_t;
  typedef struct packed {
    el_t [1:0]  pa;
    logic [3:0] w;
  } hasarr_t;
  typedef el_t uarr_t [0:1];
endpackage

interface if2_earl53;
  logic [2:0] sig;
  modport mp (input sig);
endinterface

module sink2_earl53 #(parameter int W = 8) (
  input  logic [W-1:0] d,
  output logic [W-1:0] q
);
  assign q = d;
endmodule

// The interface member connection lives one level down so the arm has a TOP
// with no unconnected interface port (Surelog and slang both reject that).
module mid2_earl53 (if2_earl53.mp itf, output logic [2:0] q_o);
  sink2_earl53 #(.W(3)) u_if (.d(itf.sig), .q(q_o));
endmodule

module a2_earl53 #(parameter int N = 2) (
  input  p2_earl53::hasarr_t ha_i,
  input  p2_earl53::uarr_t   ua_i,
  input  p2_earl53::el_t     e_i,
  output p2_earl53::el_t     e_o,
  output logic [31:0]        z_o
);
  p2_earl53::el_t    lv;          // local struct VAR
  wire p2_earl53::el_t ln;        // local struct NET
  logic [1:0] n_pa, n_ua, n_lv, n_ln, n_gs, n_gf [0:1], n_ar [0:1];
  logic [3:0] n_w;
  logic [2:0] n_if;
  logic [1:0] n_out;
  logic [1:0] n_ca;

  if2_earl53 itf_i ();
  mid2_earl53 u_mid (.itf(itf_i.mp), .q_o(n_if));

  assign lv = e_i;
  assign ln = e_i;

  // PACKED array-of-struct root, and a MID-PATH select
  sink2_earl53 #(.W(2)) u_pa (.d(ha_i.pa[1].e0), .q(n_pa));
  // UNPACKED (typedef'd) array-of-struct root
  sink2_earl53 #(.W(2)) u_ua (.d(ua_i[1].e0),    .q(n_ua));
  // a plain member of the struct that HOLDS the array
  sink2_earl53 #(.W(4)) u_w  (.d(ha_i.w),        .q(n_w));
  // local struct VAR / NET roots
  sink2_earl53 #(.W(2)) u_lv (.d(lv.e0),         .q(n_lv));
  sink2_earl53 #(.W(2)) u_ln (.d(ln.e0),         .q(n_ln));
  // OUTPUT-direction connection whose ACTUAL is a member path
  sink2_earl53 #(.W(2)) u_out(.d(e_i.e1),        .q(e_o.e0));
  // an instance ARRAY
  sink2_earl53 #(.W(2)) u_ar [0:1] (.d(e_i.e0),  .q(n_ar));

  generate
    if (N == 2) begin : g_if
      sink2_earl53 #(.W(2)) u_gs (.d({e_i.e0}),  .q(n_gs));
    end
    for (genvar gi = 0; gi < 2; gi++) begin : g_for
      sink2_earl53 #(.W(2)) u_gf (.d({e_i.e1, e_i.e0} [1:0]), .q(n_gf[gi]));
    end
  endgenerate

  assign n_ca = e_i.e0;
  assign z_o = {n_pa, n_ua, n_w, n_lv, n_ln, n_if, n_gs, n_gf[0], n_gf[1],
                n_ar[0], n_ar[1], n_ca, e_o.e1, 5'b0};
endmodule
