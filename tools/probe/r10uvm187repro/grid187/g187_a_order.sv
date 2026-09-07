// r10uvm187 arm A — NAMES, CASE, NUMBERS AND LISTING ORDER VARIED, so an arm
// that agrees with golden cannot be agreeing by coincidence of the grid's own
// spellings.  (slang rejects a package type used before its declaration, so
// the typedef leads; what varies here is which declarations sit between the
// typedef and its uses, the identifier case, and the literal shapes.)
package Aa_pkg;
  typedef int zz_T;
  parameter  zz_T ZZ_FIRST  = 101;
  typedef byte YY_t;
  parameter  int NOT_A_TD   = 202;      // a written builtin in between
  localparam YY_t yy_second = 8'd7;
  parameter  zz_T zZ_third  = -404;     // negative literal, mixed case
endpackage
package aB_PKG;
  typedef bit bb_T;
  parameter  bb_T BB_1 = 1'b1;
  typedef int Q9;
  localparam Q9 q9    = 999;
  parameter  Q9 Q9_2  = -3;
  parameter  Q9 Q9_3  = q9 + 1;         // initialiser reads another parameter
endpackage
