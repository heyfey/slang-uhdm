// r10earl88 g2 — THE BOUNDARY of § pkgScopedPaStructStrictNetVar88: the same
// two element structs (STRICT-net `f_t`, STRICT-fail `n_t`) reached through
// every SPELLING and every KEYWORD, in every direction, ANSI and non-ANSI.
// MEASUREMENT ONLY.
package q88;
  typedef struct packed { logic a; logic [3:0] b; } f_t;              // STRICT 1
  typedef struct packed { struct packed { logic q; } e; logic c; } n_t; // STRICT 0
  typedef f_t [1:0] fpa_t;   // the typedef CARRIES the packed dims
  typedef n_t [1:0] npa_t;
endpackage
typedef struct packed { logic a; logic [3:0] b; } uf_t;               // $unit
typedef struct packed { struct packed { logic q; } e; logic c; } un_t;

module leaf2 (
  // scoped, both structs, every direction
  input        q88::f_t [1:0] i_sc_f,
  output       q88::f_t [1:0] o_sc_f,
  inout        q88::f_t [1:0] b_sc_f,
  input        q88::n_t [1:0] i_sc_n,
  output       q88::n_t [1:0] o_sc_n,
  inout        q88::n_t [1:0] b_sc_n,
  // scoped + explicit keywords
  input  wire  q88::n_t [1:0] i_wire_n,
  output wire  q88::n_t [1:0] o_wire_n,
  input  var   q88::n_t [1:0] i_var_n,
  output var   q88::n_t [1:0] o_var_n,
  input  wire  q88::f_t [1:0] i_wire_f,
  input  var   q88::f_t [1:0] i_var_f,
  // the typedef already carries the dims (no WRITTEN packed dimension)
  input        q88::fpa_t     i_tdpa_f,
  input        q88::npa_t     i_tdpa_n,
  output       q88::npa_t     o_tdpa_n,
  // $unit typedefs, reached BARE
  input        uf_t [1:0]     i_un_f,
  input        un_t [1:0]     i_un_n,
  output       un_t [1:0]     o_un_n,
  // a directionless ANSI typed port
                q88::n_t [1:0] x_dirless_n
);
endmodule

// the same typedefs reached BARE through a wildcard import
module leaf2imp;
endmodule

module leaf2na (i_na_f, o_na_f, i_na_n, o_na_n, i_loc_n);   // NON-ANSI
  import q88::*;
  typedef struct packed { struct packed { logic q; } e; logic c; } loc_n_t;
  input  q88::f_t [1:0] i_na_f;
  output q88::f_t [1:0] o_na_f;
  input  q88::n_t [1:0] i_na_n;
  output q88::n_t [1:0] o_na_n;
  input  loc_n_t  [1:0] i_loc_n;      // MODULE-LOCAL typedef, bare
endmodule

module leaf2bare;                     // bare imported typedefs, BODY + ports
  import q88::*;
  f_t [1:0] w_bare_f;
  n_t [1:0] w_bare_n;
endmodule

module top88;
  q88::f_t [1:0] wf; q88::n_t [1:0] wn; q88::fpa_t wfp; q88::npa_t wnp;
  uf_t [1:0] wuf; un_t [1:0] wun;
  leaf2 u2 (.i_sc_f(wf), .o_sc_f(), .b_sc_f(), .i_sc_n(wn), .o_sc_n(), .b_sc_n(),
            .i_wire_n(wn), .o_wire_n(), .i_var_n(wn), .o_var_n(),
            .i_wire_f(wf), .i_var_f(wf),
            .i_tdpa_f(wfp), .i_tdpa_n(wnp), .o_tdpa_n(),
            .i_un_f(wuf), .i_un_n(wun), .o_un_n(), .x_dirless_n(wn));
  leaf2na u2na (.i_na_f(wf), .o_na_f(), .i_na_n(wn), .o_na_n(), .i_loc_n());
  leaf2bare u2b ();
endmodule
