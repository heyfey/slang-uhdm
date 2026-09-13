// d2 — d1's PACKAGE-HOLDER twin: the assembled localparam lives in the package
// and the module reads it qualified (p::C.n).  Same nine RHS shapes.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 3;
    r.base = 64'h1000;
    return r;
  endfunction
  localparam cfg_t C = build();
endpackage

module dut (
    output logic [95:0] o_whole,
    output logic [31:0] o_n,
    output logic [63:0] o_b,
    output logic [31:0] o_part,
    output logic        o_bit,
    output logic [31:0] o_expr,
    output logic [63:0] o_cat,
    output logic [7:0]  o_narrow,
    output logic [63:0] o_wide
);
  assign o_whole  = p::C;
  assign o_n      = p::C.n;
  assign o_b      = p::C.base;
  assign o_part   = p::C.base[31:0];
  assign o_bit    = p::C.base[12];
  assign o_expr   = p::C.n + 1;
  assign o_cat    = {p::C.n, p::C.n};
  assign o_narrow = p::C.n;
  assign o_wide   = p::C.n;
endmodule
