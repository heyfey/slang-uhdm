// r10earl36 a2 — THE OVER-FIRE CONTROL.
//
// a1 shows that a module parameter SHADOWING a wildcard-imported package member
// folds to the PACKAGE value.  The only thing that could make that rule fire
// where golden does not is the IMPORT being irrelevant — i.e. golden folding on
// the mere EXISTENCE of a same-named package member.  This arm removes the
// import and keeps everything else identical, in both carriers and both
// positions.  If golden keeps `ref_obj` here, the import is load-bearing and
// `wildcardPkgParamNamed9`'s walk is the right instrument.
//
// It also carries the HEADER-import variant (m36c), because flash_mp's import
// is in the BODY and a header import changes what slang's own Lookup sees in
// the PORT LIST — the two must be measured apart.
package q2;
  localparam int SH_P  = 5;
  localparam int OTHER = 3;
  typedef struct packed { logic q; } f_t;
endpackage

// (a) NO import at all — the package member exists but is not imported here.
module m36b #(
  parameter  int SH_P   = 9,
  localparam int SH_LP2 = 9
) (
  input logic clk_i,
  input q2::f_t [SH_P-1:0]  n_shp,      // packed carrier, no import
  input logic   [SH_P-1:0]  n_bshp,     // logic carrier, no import
  output logic              o_o
);
  q2::f_t [SH_P-1:0] n_body;
  logic   [SH_LP2-1:0] n_blp;
  assign o_o = clk_i;
  assign n_body = '0;
  assign n_blp = '0;
endmodule

// (b) HEADER import — visible to slang's own port-list lookup.
module m36c
  import q2::*;
#(
  parameter  int SH_P   = 9,
  localparam int SH_LP3 = 9
) (
  input logic clk_i,
  input q2::f_t [SH_P-1:0]  h_shp,
  input q2::f_t [OTHER-1:0] h_other,    // package-ONLY name, bare, in the ports
  input logic   [SH_P-1:0]  h_bshp,
  output logic              o_o
);
  assign o_o = clk_i;
endmodule

module top2;
  logic clk;
  logic o1, o2;
  m36b u1 (.clk_i(clk), .o_o(o1), .n_shp(), .n_bshp());
  m36c u2 (.clk_i(clk), .o_o(o2), .h_shp(), .h_other(), .h_bshp());
endmodule
