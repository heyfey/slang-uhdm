// r10v106 va3_span106 — THE KEY-COLLISION ATTACK.  `applyCaCastAdjust106`
// keys its record on (gen-scope FULLNAME, cont_assign SPAN) and inserts with
// `std::map::emplace`, so the FIRST record wins any key collision.  Two
// cont_assigns in ONE gen scope that share a span therefore both take the
// FIRST one's Lhs width.  Macro expansion is the way to make two assigns share
// a span; the two Lhs widths here (4 and 16) differ, so if the spans collide
// the second cell must go AWAY from golden.  MEASUREMENT ONLY.
package pv3_106;
  parameter int unsigned P8 = 8;
endpackage

`define TWO106 assign a4x = pv3_106::P8'(6'h3F); assign a16x = pv3_106::P8'(6'h3F);
`define ONE106(n) assign n = pv3_106::P8'(6'h3F);

module va3_span106 (output logic o);
  logic [3:0]  a4x,  b4x,  c4x,  d4x,  e4x;
  logic [15:0] a16x, b16x, c16x, d16x, e16x;

  // A: ONE macro invocation expanding to TWO cont_assigns in one gen scope.
  if (1) begin : m_two
    `TWO106
  end

  // B: TWO invocations of a one-assign macro on the SAME LINE.
  if (1) begin : m_one2
    `ONE106(b4x) `ONE106(b16x)
  end

  // C: the same two assigns written out, distinct spans (the control).
  if (1) begin : m_plain
    assign c4x  = pv3_106::P8'(6'h3F);
    assign c16x = pv3_106::P8'(6'h3F);
  end

  // D: ONE `assign` statement with a COMMA LIST — two cont_assign objects out
  //    of one piece of syntax, the likeliest span collision in legal SV.
  if (1) begin : m_comma
    assign d4x = pv3_106::P8'(6'h3F), d16x = pv3_106::P8'(6'h3F);
  end

  // E: the same comma list with the WIDE target FIRST (emplace keeps the first
  //    record, so the two orders must both be checked).
  if (1) begin : m_comma2
    assign e16x = pv3_106::P8'(6'h3F), e4x = pv3_106::P8'(6'h3F);
  end

  assign o = a4x[0] ^ b4x[0] ^ c4x[0] ^ a16x[0] ^ b16x[0] ^ c16x[0]
           ^ d4x[0] ^ d16x[0] ^ e4x[0] ^ e16x[0];
endmodule
