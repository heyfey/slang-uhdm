// r10earl45 — THE OVER-FIRE PROBE THE BYTE VERIFIER FOUND.
//
// GATE 5 reported FIVE movers, not the ONE this pass predicted.  Two of the
// three unexpected names are `Kmac` and `BlackBePipeInt`, whose dumps are
// BYTE-IDENTICAL between the two binaries and which are CMP_EQUAL to each
// other -- but whose DATABASES differ (+4 B and +12 B, i.e. 1 and 3 stamps at
// the 4 bytes-per-stamp rate Earlgrey's +8 for its 2 known stamps establishes).
//
// `Surelog/tests/Kmac/sha3_pkg.sv:20` is the shape:
//
//     parameter int unsigned KeccakRate [5] = '{ 1344/MsgWidth, ... };
//
// a ONE-DIMENSIONAL unpacked array whose elements are ARITHMETIC OPERATIONS.
// `stamp45` only checks that the first operand IS an `operation` -- and a
// division op is one.  `a1_earl45 h45o_flat` looked like the control for this
// ("1-D array, nothing stamped") but its elements are CONSTANTS, so it can
// never fire the arm and never proved anything about this shape.
//
// These cells ask golden directly: does the first operand of a 1-D unpacked
// pattern get a size when that operand is an EXPRESSION rather than a row?

// A — the Kmac shape, in a MODULE localparam.
module a45x_exprflat;
  localparam int T [5] = '{1344/64, 1152/64, 1088/64, 832/64, 576/64};
endmodule

// B — the Kmac shape verbatim: a PACKAGE parameter, read from a module.
package b45x_pkg;
  parameter int unsigned MsgWidth = 64;
  parameter int unsigned KR [5] = '{1344/MsgWidth, 1152/MsgWidth,
                                    1088/MsgWidth, 832/MsgWidth,
                                    576/MsgWidth};
endpackage
module b45x_use;
  import b45x_pkg::*;
  localparam int U = KR[0];
endmodule

// C — a 1-D unpacked array of CONCATENATIONS (an operation that is not
//     arithmetic and not a pattern).
module c45x_concat;
  localparam logic [7:0] T [2] = '{{4'h1,4'h2}, {4'h3,4'h4}};
endmodule

// D — a 1-D unpacked array whose first element is an expression and whose
//     rest are constants (the operand kinds are MIXED).
module d45x_mixed;
  localparam int T [3] = '{1344/64, 2, 3};
endmodule

// E — a 1-D unpacked array whose FIRST element is a constant and whose LAST
//     is an expression, with a DESCENDING range so the list reverses and the
//     expression lands at `front()`.
module e45x_descexpr;
  localparam int T [2:0] = '{1, 2, 1344/64};
endmodule

// F — the CONTROL that already existed, restated: 1-D, all constants.
module f45x_flatconst;
  localparam int T [3] = '{1,2,3};
endmodule

// G — a 2-D table whose ROWS are patterns (the law's own shape) sitting beside
//     the 1-D expression cells, so one file answers both questions.
module g45x_table;
  localparam int T [2][3] = '{'{1,2,3},'{4,5,6}};
endmodule
