// r10earl32 VERIFIER arm v1 — THE TEXT TEST THE IMPLEMENTER'S a4 DID NOT BUILD.
//
// § fcArgFoldParent32 decides the FOLDED CONSTANT'S vpiParent with
//     rawText(expr.sourceRange).find("::") != npos  ->  QUALIFIED
// and a4_text.sv measured escaped identifiers (`\p@x`) and macro-written
// spellings — but NOT the one spelling where the text test and the meaning come
// apart: an ESCAPED IDENTIFIER WHOSE NAME CONTAINS "::".  Read BARE after a
// wildcard import, `\a::b ` has "::" in its raw text and NO package qualifier at
// all, so the shipped test must call it QUALIFIED and parent the constant at the
// CALL, where the bare law (a4 e8/e9/e10) parents it at the package param_assign.
//
// v1a  qualified   mf(m32v::\a::b )   -> text says QUALIFIED, meaning QUALIFIED
// v1b  BARE        mf(\a::b )         -> text says QUALIFIED, meaning BARE  <== the cell
// v1c  BARE ctrl   mf(\pl )           -> escaped, NO colons: the control
package m32v;
  localparam logic [11:0] \a::b  = 12'h380;
  localparam logic [11:0] \pl    = 12'h381;
endpackage

module m32va (output logic [31:0] o1);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  assign o1 = mf(m32v::\a::b );              // v1a
endmodule

module m32vb (output logic [31:0] o1, o2);
  import m32v::*;
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  assign o1 = mf(\a::b );                    // v1b  <== THE CELL
  assign o2 = mf(\pl );                      // v1c  control
endmodule

module m32vtop;
  logic [31:0] a1, b1, b2;
  m32va ua (.o1(a1));
  m32vb ub (.o1(b1), .o2(b2));
endmodule
