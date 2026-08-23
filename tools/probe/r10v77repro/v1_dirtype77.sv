// r10v77 -- ADVERSARIAL grid A: direction x written-type, module home, ANSI.
// three instances: two driven, one UNDRIVEN.  MEASUREMENT ONLY.
package a77;
  typedef logic [7:0]              v8_t;
  typedef logic                    s1_t;
  typedef logic signed [7:0]       sv_t;
  typedef bit   [7:0]              b8_t;
  typedef enum logic [1:0] { A770, A771 } e_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } st_t;
  typedef struct packed { bit [3:0] x; bit [3:0] y; } bst_t;
  typedef logic [1:0][3:0]         m_t;
  parameter int AW = 8;
  typedef logic [AW-1:0]           pw_t;
  typedef v8_t                     nest_t;      // typedef-of-typedef
endpackage

typedef logic [7:0] g8_t;   // $unit

module leafA import a77::*; (
  input                 i_bare,
  input  logic          i_lsc,
  input  logic [7:0]    i_lvec,
  input  wire           i_wsc,
  input  wire [7:0]     i_wvec,
  input  var logic[7:0] i_varvec,
  input  a77::v8_t      i_pv,
  input  a77::s1_t      i_ps,
  input  a77::sv_t      i_psg,
  input  a77::pw_t      i_ppw,
  input  a77::m_t       i_pm,
  input  a77::nest_t    i_pn,
  input  a77::b8_t      i_pb,
  input  a77::e_t       i_pe,
  input  a77::st_t      i_pst,
  input  a77::bst_t     i_pbst,
  input  v8_t           i_imp,
  input  g8_t           i_unit,
  output                o_bare,
  output logic          o_lsc,
  output logic [7:0]    o_lvec,
  output wire           o_wsc,
  output wire [7:0]     o_wvec,
  output var logic[7:0] o_varvec,
  output a77::v8_t      o_pv,
  output a77::s1_t      o_ps,
  output a77::sv_t      o_psg,
  output a77::pw_t      o_ppw,
  output a77::m_t       o_pm,
  output a77::nest_t    o_pn,
  output a77::b8_t      o_pb,
  output a77::e_t       o_pe,
  output a77::st_t      o_pst,
  output a77::bst_t     o_pbst,
  output v8_t           o_imp,
  output g8_t           o_unit,
  inout  a77::v8_t      b_pv,
  inout  wire a77::v8_t b_pvw,
  inout  logic [7:0]    b_lvec,
  inout  a77::e_t       b_pe,
  inout  a77::st_t      b_pst
);
  assign o_bare = i_bare;
  assign o_lsc  = i_lsc;
  assign o_lvec = i_lvec;
  assign o_wsc  = i_wsc;
  assign o_wvec = i_wvec;
  assign o_varvec = i_varvec;
  assign o_pv   = i_pv;
  assign o_ps   = i_ps;
  assign o_psg  = i_psg;
  assign o_ppw  = i_ppw;
  assign o_pm   = i_pm;
  assign o_pn   = i_pn;
  assign o_pb   = i_pb;
  assign o_pe   = i_pe;
  assign o_pst  = i_pst;
  assign o_pbst = i_pbst;
  assign o_imp  = i_imp;
  assign o_unit = i_unit;
endmodule

module topA;
  logic i_bare, i_lsc, i_wsc, o_bare1, o_lsc1, o_wsc1, o_bare2, o_lsc2, o_wsc2;
  logic [7:0] v1, v2, v3, v4, v5, v6, v7, v8;
  logic [7:0] w1, w2, w3, w4, w5, w6, w7, w8;
  logic [1:0][3:0] m1, m2;
  bit   [7:0] bb1, bb2;
  a77::e_t   e1, e2;
  a77::st_t  s1, s2;
  a77::bst_t bs1, bs2;
  wire  [7:0] z1, z2, z3;
  wire a77::e_t ze;
  wire a77::st_t zs;
  leafA u_a1 (.i_bare(i_bare), .i_lsc(i_lsc), .i_lvec(v1), .i_wsc(i_wsc), .i_wvec(v2),
    .i_varvec(v3), .i_pv(v4), .i_ps(i_lsc), .i_psg(v5), .i_ppw(v6), .i_pm(m1),
    .i_pn(v7), .i_pb(bb1), .i_pe(e1), .i_pst(s1), .i_pbst(bs1), .i_imp(v8), .i_unit(v1),
    .o_bare(o_bare1), .o_lsc(o_lsc1), .o_lvec(w1), .o_wsc(o_wsc1), .o_wvec(w2),
    .o_varvec(w3), .o_pv(w4), .o_ps(o_lsc2), .o_psg(w5), .o_ppw(w6), .o_pm(m2),
    .o_pn(w7), .o_pb(bb2), .o_pe(e2), .o_pst(s2), .o_pbst(bs2), .o_imp(w8), .o_unit(w1),
    .b_pv(z1), .b_pvw(z2), .b_lvec(z3), .b_pe(ze), .b_pst(zs));
  leafA u_a2 (.i_bare(i_bare), .i_lsc(i_lsc), .i_lvec(v1), .i_wsc(i_wsc), .i_wvec(v2),
    .i_varvec(v3), .i_pv(v4), .i_ps(i_lsc), .i_psg(v5), .i_ppw(v6), .i_pm(m1),
    .i_pn(v7), .i_pb(bb1), .i_pe(e1), .i_pst(s1), .i_pbst(bs1), .i_imp(v8), .i_unit(v1),
    .o_bare(o_bare2), .o_lsc(o_lsc2), .o_lvec(), .o_wsc(o_wsc2), .o_wvec(),
    .o_varvec(), .o_pv(), .o_ps(), .o_psg(), .o_ppw(), .o_pm(),
    .o_pn(), .o_pb(), .o_pe(), .o_pst(), .o_pbst(), .o_imp(), .o_unit(),
    .b_pv(z1), .b_pvw(z2), .b_lvec(z3), .b_pe(ze), .b_pst(zs));
  leafA u_a3 ();   // UNDRIVEN
endmodule
