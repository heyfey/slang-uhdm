// r10v188repro/arms/v188_f_fold.sv — THE FOLDED LISTING'S SIZE.
// § enumConstLitArithRender188 states the elaborated listing's size is 64 for
// a top-level SHIFT and otherwise the DEFINITION listing's modelled size.
// These shapes separate that from the alternative "64 whenever the fold
// encodes INT (i.e. the expression contains - * /)": every row below carries a
// NARROW modelled size (4, 3, 0) so the two rules predict different numbers.
// Also the REFERENCE sites of a SHIFT-shaped constant, where the folded
// `constant`'s own VpiSize is a compared field.
package v188f_pkg;
  typedef enum longint unsigned {
    F_MUL4  = 4'hF * 4'h3,
    F_SUB4  = 4'hC - 4'h2,
    F_DIV4  = 4'hC / 4'h2,
    F_ADD4  = 4'h5 + 4'h3,
    F_MULU  = 'h6 * 'h3,
    F_SUBU  = 'h9 - 'h2,
    F_ADDU  = 'h9 + 'h2,
    F_NEST1 = 4'h2 + 4'h1 - 4'h1,
    F_NEST2 = 4'h4 - 4'h1 + 4'h6,
    F_NEST3 = 3'h1 + 3'h1 * 3'h3,
    F_SHADD = (1 << 2) + 3'h1,
    F_ADDSH = 3'h1 + (1 << 4),
    F_SHSUB = (1 << 4) - 3'h1,
    F_SHM   = 8'h2 << 3
  } v188f_e;

  typedef enum { F_REFSRC = 1 << 6, F_REFSRC2 = 3 + 5 } v188f_ref_e;
endpackage

module v188f_top;
  import v188f_pkg::*;
  localparam int F_R0 = v188f_pkg::F_REFSRC;
  localparam int F_R1 = v188f_pkg::F_REFSRC2;
  int f0;
  initial f0 = v188f_pkg::F_REFSRC;
endmodule
