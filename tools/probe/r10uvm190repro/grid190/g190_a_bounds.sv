// r10uvm190 arm A — WHAT THE TYPEDEF'S PACKED-RANGE BOUND IS.
// One package, one enum per typedef, and the bound varied over every shape
// this pass's gate can meet: a parameter READ inside an operation, a BARE
// parameter read (no operation above it), a localparam, a plain literal (which
// folds and holds no reference at all), a two-operand expression, a two-
// DIMENSIONAL typedef, and a bound reading a parameter of ANOTHER package.
//
// The question each cell answers: does golden's ENUM-BASE clone bind the
// reference inside its own copy of that bound, or leave it dangling?
package pkx190;
  parameter XW = 12;
endpackage

package pka190;
  import pkx190::*;
  parameter  PW  = 28;
  localparam LW  = 20;

  // a1 — the head's own shape: parameter read under an operation
  typedef bit [PW-1 : 0]        t_op;
  typedef enum t_op   { a1_0 = 0, a1_1 = 1 } e_op;

  // a2 — a BARE parameter read as the bound, no operation above it
  typedef bit [PW : 0]          t_bare;
  typedef enum t_bare { a2_0 = 0, a2_1 = 1 } e_bare;

  // a3 — a LOCALPARAM read
  typedef bit [LW-1 : 0]        t_lp;
  typedef enum t_lp   { a3_0 = 0, a3_1 = 1 } e_lp;

  // a4 — a plain literal bound: no reference exists, the gate must abstain
  typedef bit [15 : 0]          t_lit;
  typedef enum t_lit  { a4_0 = 0, a4_1 = 1 } e_lit;

  // a5 — two operands, both parameter reads
  typedef bit [PW-LW : 0]       t_two;
  typedef enum t_two  { a5_0 = 0, a5_1 = 1 } e_two;

  // a6 — a bound whose operation READS THE PARAMETER TWICE
  typedef bit [PW-PW+7 : 0]     t_2d;
  typedef enum t_2d   { a6_0 = 0, a6_1 = 1 } e_2d;

  // a7 — a bound reading ANOTHER package's parameter
  typedef bit [pkx190::XW-1 : 0] t_xpkg;
  typedef enum t_xpkg { a7_0 = 0, a7_1 = 1 } e_xpkg;

  // a8 — a `logic` base rather than `bit`
  typedef logic [PW-1 : 0]      t_log;
  typedef enum t_log  { a8_0 = 0, a8_1 = 1 } e_log;

  // a9 — an UNSIGNED-cast / concatenation bound (outside the copier's node set:
  // the gate must ABSTAIN and share, exactly as before this pass)
  typedef bit [{1'b1, 1'b0} : 0] t_cat;
  typedef enum t_cat  { a9_0 = 0, a9_1 = 1 } e_cat;
endpackage

module g190_a;
  pka190::e_op    v1;
  pka190::e_bare  v2;
  pka190::e_lp    v3;
  pka190::e_lit   v4;
  pka190::e_two   v5;
  pka190::e_2d    v6;
  pka190::e_xpkg  v7;
  pka190::e_log   v8;
  pka190::e_cat   v9;
  initial begin
    v1 = pka190::a1_1; v2 = pka190::a2_1; v3 = pka190::a3_1;
    v4 = pka190::a4_1; v5 = pka190::a5_1; v6 = pka190::a6_1;
    v7 = pka190::a7_1; v8 = pka190::a8_1; v9 = pka190::a9_1;
  end
endmodule
