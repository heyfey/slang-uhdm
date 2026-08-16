// r10earl45 — the OVER-FIRE / ORDER probe.
//
// a1_earl45 established that golden stamps |vpiSize| on EXACTLY ONE nested
// pattern op — the FIRST direct operand of the OUTERMOST pattern op — in the
// module ELAB listing, with the value = the width of the type left after
// stripping the UNPACKED dimensions.  ONE cell contradicted "exactly one":
// `k45_desc` (`int T [1:0][2:0]`), whose outer range is DESCENDING and which
// carries TWO stamped rows.
//
// These cells separate the candidate rules on the reordered shape:
//   H-A  "the first operand of the STORED list"   (post-reverse front)
//   H-B  "the first operand in SOURCE order"      (pre-reverse front)
//   H-C  "the union of the two"                   (2 cells iff reordered)
//   H-D  "the first AND last of the stored list"  (2 cells always when n>=2)
// H-A/H-B/H-C/H-D all agree on 2 ascending rows; a THREE-row descending table
// separates H-C (2 stamps) from H-D (2 stamps but DIFFERENT cells) and from
// "all rows" (3 stamps).

// A — THREE rows, ASCENDING outer.  H-D would stamp rows 0 and 2.
module a45o_asc3;
  localparam int T [3][2] = '{'{1,2},'{3,4},'{5,6}};
endmodule

// B — THREE rows, DESCENDING outer.  Stored order is row2,row1,row0.
//     H-A -> the `'{5,6}` row only; H-B -> `'{1,2}` only;
//     H-C -> both of those; H-D -> `'{5,6}` and `'{1,2}` (the same two!).
//     So B separates H-A/H-B (1 stamp) from H-C/H-D (2 stamps).
module b45o_desc3;
  localparam int T [2:0][1:0] = '{'{1,2},'{3,4},'{5,6}};
endmodule

// C — FOUR rows, DESCENDING outer.  NOW H-C and H-D differ:
//     H-C stamps the stored-first (`'{7,8}`) and the source-first (`'{1,2}`)
//     -- which are also the stored-first and stored-LAST, so they still
//     coincide.  Kept as the population check: 2 stamps, not 4.
module c45o_desc4;
  localparam int T [3:0][1:0] = '{'{1,2},'{3,4},'{5,6},'{7,8}};
endmodule

// D — outer DESCENDING, inner ASCENDING.
module d45o_descasc;
  localparam int T [2:0][2] = '{'{1,2},'{3,4},'{5,6}};
endmodule

// E — outer ASCENDING, inner DESCENDING.
module e45o_ascdesc;
  localparam int T [3][1:0] = '{'{1,2},'{3,4},'{5,6}};
endmodule

// F — the table in an INSTANTIATED module, not a top.  Earlgrey's prim_keccak
//     is an un-instantiated top; this cell proves the law is not a top-only
//     accident.
module f45o_inner;
  localparam int T [3][2] = '{'{1,2},'{3,4},'{5,6}};
endmodule
module f45o_top;
  f45o_inner u_i ();
endmodule

// G — a STRUCT element type.
package g45o_pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } sp_t;
endpackage
module g45o_struct;
  import g45o_pkg::*;
  localparam sp_t T [2][2] = '{'{'{a:8'h1,b:8'h2},'{a:8'h3,b:8'h4}},
                               '{'{a:8'h5,b:8'h6},'{a:8'h7,b:8'h8}}};
endmodule

// H — a ONE-dimensional unpacked array: there are NO nested pattern ops at
//     all, so nothing may be stamped.  The negative control for "depth 1".
module h45o_flat;
  localparam int T [3] = '{1,2,3};
endmodule

// I — nested patterns under a NON-pattern outermost (a concat).  The law
//     keys on the outermost PATTERN op; this cell must not move.
module i45o_concat;
  localparam logic [63:0] T = {32'h1, 32'h2};
endmodule

// J — a pattern with `default:`.
module j45o_default;
  localparam int T [2][3] = '{default:7};
endmodule

// K — an unpacked array param whose rows are written as REPLICATIONS.
module k45o_repl;
  localparam int T [2][3] = '{2{'{1,2,3}}};
endmodule

// L — a CONT-ASSIGN Rhs pattern-of-patterns, modelled verbatim on
//     rv_timer.sv:64 (`assign mtimecmp = '{'{{hi,lo}}};`).  That cell is the
//     ONLY OTHER depth-1 / operand-index-0 op75 in Earlgrey's ELAB listing
//     (census45 Q6, both sides) and golden leaves it UNSIZED.  The law's CODE
//     gate is `inParamInit && !paramInitDef`, so a cont-assign Rhs never
//     reaches the stamp; this cell is the probe that says so.
module l45o_ca (output logic [63:0] mtimecmp [1][1]);
  logic [31:0] hi, lo;
  assign mtimecmp = '{'{{hi, lo}}};
endmodule

// M — a pattern-of-patterns as a FUNCTION ARGUMENT (neither a param init nor
//     a cont-assign): the second negative control on the `inParamInit` gate.
module m45o_arg;
  function automatic int f45(input int a [2][2]);
    return a[0][0];
  endfunction
  localparam int R = f45('{'{1,2},'{3,4}});
endmodule
