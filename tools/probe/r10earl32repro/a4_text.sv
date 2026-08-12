// r10earl32 arm 4 - THE TEXT-TEST ARM.  MANDATORY, NOT OPTIONAL.
//
// The gate this pass adds reads NO text (see the law), but the code it hands
// the fold to does: the CARVE-OUT body it preserves and the
// fcArgFoldParent32 block it adds both split on
// rawText(expr.sourceRange).find("::").  The standing law says every gate that
// reads names or raw text must be measured against ESCAPED IDENTIFIERS and
// MACRO-WRITTEN SPELLINGS, because those are the two spellings where the
// written text and the resolved meaning come apart:
//
//   * a MACRO-written qualified read has NO "::" in its own source range (the
//     range is the macro CALL) - a text test reads it as BARE;
//   * an ESCAPED identifier can contain any character at all, including the
//     ":" a name test would key on.
//
// e1/e2 are the pair that matters: the SAME parameter, one written m32::P,
// one written `QP which expands to exactly that.
//
// NOTE: an ESCAPED PACKAGE NAME (`package \m32$esc ;` read as
// `\m32$esc ::E`) was built as cell e5 and REMOVED - Surelog aborts during
// "Compile package" on it, so that cell is UNMEASURABLE against this golden
// and is recorded as such rather than guessed.
`define QP m32::P
`define QCALL mf(m32::P)
`define BP P

package m32;
  localparam logic [11:0] P = 12'h380;
  localparam logic [11:0] \p@x  = 12'h222;
endpackage

module m32a (
  input  logic [2:0]  s_i,
  output logic [31:0] o1, o2, o3, o4, o6, o7, o8
);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  // a formal WIDER than the parameter - does the fold resize to the formal?
  function automatic logic [31:0] mw(logic [19:0] v); return {v, 12'h0}; endfunction
  // an int formal
  function automatic logic [31:0] mi(int v);          return v;          endfunction

  assign o1 = mf(m32::P);                    // e1  QUALIFIED, written out
  assign o2 = mf(`QP);                       // e2  QUALIFIED, MACRO-WRITTEN
  assign o3 = `QCALL;                        // e3  the WHOLE CALL macro-written
  assign o4 = mf(m32::\p@x );                // e4  ESCAPED param name, qualified
  assign o6 = mw(m32::P);                    // e6  formal WIDER than the param
  assign o7 = mi(m32::P);                    // e7  int formal
  assign o8 = 32'(s_i);
endmodule

// the BARE (wildcard-import) half of each spelling
module m32b (
  output logic [31:0] o1, o2, o3
);
  import m32::*;
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  assign o1 = mf(P);                         // e8  BARE, written out
  assign o2 = mf(`BP);                       // e9  BARE, MACRO-WRITTEN
  assign o3 = mf(\p@x );                     // e10 BARE, ESCAPED param name
endmodule

module m32top;
  logic [2:0] s;
  logic [31:0] a1,a2,a3,a4,a6,a7,a8,b1,b2,b3;
  m32a ua (.s_i(s), .o1(a1), .o2(a2), .o3(a3), .o4(a4), .o6(a6),
           .o7(a7), .o8(a8));
  m32b ub (.o1(b1), .o2(b2), .o3(b3));
endmodule
