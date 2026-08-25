// r10v88 v2 — ADVERSARIAL: dimension forms x directions x declaration styles.
// MEASUREMENT ONLY.
package s88;
  parameter int NP = 2;
  typedef struct packed { logic a; logic [3:0] b; }        f_t;   // STRICT 1
  typedef struct packed { struct packed { logic q; } e; logic c; } n_t; // STRICT 0
  typedef f_t [1:0] fpa_t;    // typedef CARRIES the dims (all-logic element)
  typedef n_t [1:0] npa_t;    // typedef CARRIES the dims (nested element)
endpackage

module vleaf2 #(parameter int P = 2) (
  // parameterised / package-parameter bounds
  input  s88::f_t [P-1:0]      i_f_pp,     output s88::f_t [P-1:0]      o_f_pp,
  input  s88::n_t [P-1:0]      i_n_pp,     output s88::n_t [P-1:0]      o_n_pp,
  input  s88::f_t [s88::NP-1:0] i_f_pk,    output s88::f_t [s88::NP-1:0] o_f_pk,
  input  s88::n_t [s88::NP-1:0] i_n_pk,    output s88::n_t [s88::NP-1:0] o_n_pk,
  // packed + UNPACKED
  input  s88::f_t [1:0]        i_f_pu [3], output s88::f_t [1:0]        o_f_pu [3],
  input  s88::n_t [1:0]        i_n_pu [3], output s88::n_t [1:0]        o_n_pu [3],
  // typedef-carried dims, and declaration dims ON TOP of typedef dims
  input  s88::fpa_t            i_f_td,     output s88::fpa_t            o_f_td,
  input  s88::npa_t            i_n_td,     output s88::npa_t            o_n_td,
  input  s88::fpa_t [1:0]      i_f_tdd,    output s88::fpa_t [1:0]      o_f_tdd,
  input  s88::npa_t [1:0]      i_n_tdd,    output s88::npa_t [1:0]      o_n_tdd,
  // inout on both structs
  inout  s88::f_t [1:0]        b_f,        inout  s88::n_t [1:0]        b_n,
  // three packed dims
  input  s88::n_t [1:0][2:0][3:0] i_n_d3
);
endmodule

// NON-ANSI with SEPARATE net / var declarations
module vleaf2na (i_f, o_f, i_n, o_n, i_nw, i_nv, i_fv);
  input  s88::f_t [1:0] i_f;
  output s88::f_t [1:0] o_f;
  input  s88::n_t [1:0] i_n;
  output s88::n_t [1:0] o_n;
  input  i_nw;  wire s88::n_t [1:0] i_nw;      // separate NET declaration
  input  i_nv;  var  s88::n_t [1:0] i_nv;      // separate VAR declaration
  input  i_fv;  var  s88::f_t [1:0] i_fv;
endmodule

// ANSI ports with DEFAULT values
module vleaf2def (
  input s88::f_t [1:0] i_f_def = '0,
  input s88::n_t [1:0] i_n_def = '0
);
endmodule

interface vif88;
  s88::f_t [1:0] if_f;
  s88::n_t [1:0] if_n;
  modport mp (input if_f, output if_n);
endinterface

module vleaf2if (vif88 vif, vif88.mp vmp,
                 input s88::n_t [1:0] i_n_if);
endmodule

module vtop2;
  s88::f_t [1:0] w_f;   s88::n_t [1:0] w_n;
  s88::f_t [1:0] w_fo;  s88::n_t [1:0] w_no;
  s88::fpa_t     w_ftd; s88::npa_t     w_ntd;
  s88::n_t [1:0] w_n2 [3];
  s88::f_t [1:0] w_f2;  s88::n_t [1:0] w_n3;
  vif88 the_if ();
  vleaf2 #(.P(2)) u_a (.i_f_pp(w_f), .o_f_pp(w_fo), .i_n_pp(w_n), .o_n_pp(w_no),
                       .i_f_td(w_ftd), .i_n_td(w_ntd), .i_n_pu(w_n2));
  vleaf2 #(.P(3)) u_b ();
  vleaf2 #(.P(2)) u_c ();
  vleaf2na   u_na (.i_f(w_f), .o_f(), .i_n(w_n), .o_n(), .i_nw(w_n), .i_nv(w_n), .i_fv(w_f));
  vleaf2def  u_df ();
  vleaf2if   u_if (.vif(the_if), .vmp(the_if.mp), .i_n_if(w_n));
endmodule
