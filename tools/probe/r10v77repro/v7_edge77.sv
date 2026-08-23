// r10v77 -- ADVERSARIAL grid G: the arm's NEIGHBOURS.  A package `reg` typedef
// (the regDecl fence), a $unit typedef SPELLED SCOPED, a TOP-LEVEL module whose
// ports carry the shape (no parent instance), a 2-state and a real/string
// package typedef, and a package typedef used on a port that ALSO has a body
// declaration.
package g77;
  typedef logic [7:0]  v8_t;
  typedef reg   [7:0]  rg_t;
  typedef bit   [7:0]  b8_t;
  typedef real         r_t;
  typedef logic [7:0]  vv_t;
endpackage

typedef logic [7:0] uu_t;

// TOP-LEVEL module: never instantiated by anything in this file.
module topleafG (
  input  g77::v8_t t_pv,
  output g77::v8_t t_pvo,
  input  logic [7:0] t_plain
);
  assign t_pvo = t_pv;
endmodule

module leafG (
  input  g77::rg_t   g_reg,
  output g77::rg_t   g_rego,
  input  $unit::uu_t g_unitsc,
  output $unit::uu_t g_unitsco,
  input  g77::b8_t   g_bit,
  input  g77::r_t    g_real,
  input  g77::vv_t   g_bodyport,
  output g77::v8_t   g_pvo
);
  logic [7:0] g_bodyport_copy;
  assign g_rego    = g_reg;
  assign g_unitsco = g_unitsc;
  assign g_pvo     = g_bodyport;
endmodule

module topG;
  logic [7:0] a, b, c, d, e, f;
  bit   [7:0] bb;
  real        rr;
  leafG u_g (.g_reg(a), .g_rego(b), .g_unitsc(c), .g_unitsco(d),
             .g_bit(bb), .g_real(rr), .g_bodyport(e), .g_pvo(f));
endmodule
