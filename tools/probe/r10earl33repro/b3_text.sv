// r10earl33 arm 3 — THE MANDATORY TEXT ARM, at the def-view gen-CA position.
//
// The standing law: every gate that reads a NAME or a TEXT must be measured
// against a MACRO-WRITTEN and an ESCAPED-IDENTIFIER spelling.  r10earl32's F1
// is the campaign's own counterexample — an escaped identifier whose NAME
// contains `::` makes a `rawText(...).find("::")` test read BARE as QUALIFIED.
// This arm builds that exact spelling one container in.
`define QP p33b::P
`define QCALL mf(p33b::P)

package p33b;
  localparam logic [11:0] P     = 12'h380;
  localparam logic [11:0] \e@x  = 12'h381;   // ESCAPED, no `::` in the name
  localparam logic [11:0] \a::b = 12'h382;   // ESCAPED, name CONTAINS `::`
  localparam logic [11:0] R     = 12'h383;
endpackage

package p33c;
  import p33b::*;
  function automatic logic [31:0] cfn(logic [11:0] v); return {v, 20'h0}; endfunction
  // s1  a PACKAGE localparam init that is a call on its OWN package's param
  localparam logic [11:0] S = 12'h384;
  localparam int G1 = cfn(S);
  // s2  ...and on ANOTHER package's, qualified (r10earl32 R4 — must not move)
  localparam int G2 = cfn(p33b::R);
endpackage

module t33 (output logic [31:0] y);
  import p33b::*;
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction

  logic [31:0] r1, r2, r3, r4, r5, r6;
  for (genvar gi = 0; gi < 2; gi++) begin : gt
    logic [31:0] w1, w2, w3, w4, w5, w6;
    assign w1 = mf(p33b::P);        // e1  written out, qualified
    assign w2 = mf(`QP);            // e2  the SAME read, MACRO-written
    assign w3 = `QCALL;             // e3  the WHOLE call macro-written
    assign w4 = mf(p33b::\e@x );    // e4  ESCAPED param name, qualified
    assign w5 = mf(p33b::\a::b );   // e5  ESCAPED name CONTAINING `::`
    assign w6 = mf(P);              // e6  BARE after a wildcard import
  end
  assign r1 = gt[0].w1;
  assign r2 = gt[0].w2;
  assign r3 = gt[0].w3;
  assign r4 = gt[0].w4;
  assign r5 = gt[0].w5;
  assign r6 = gt[0].w6;
  assign y = r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6 ^ 32'(p33c::G1) ^ 32'(p33c::G2);
endmodule

module t33top;
  logic [31:0] a;
  t33 u1 (.y(a));
endmodule
