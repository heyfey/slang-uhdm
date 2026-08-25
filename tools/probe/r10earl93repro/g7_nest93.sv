// r10earl93 g7 -- THE NESTED-CAST CHAIN GRID.  ExprEval reduces the operand
// first, so a chain of size casts ANDs its masks; this arm measures every
// outer/inner width pairing that matters, including the pairings where slang
// COLLAPSES the inner cast out of the AST and the chain cannot see it.
// MEASUREMENT ONLY.
module g7;
  localparam A = 64'hFFFFFFFFFFFFFFFF;
  // outer WIDER than inner -- slang keeps both ConversionExpressions
  localparam n_96_65  = 96'(65'(64'hFFFFFFFFFFFFFFFF));
  localparam n_96_64  = 96'(64'(64'hFFFFFFFFFFFFFFFF));
  localparam n_96_63  = 96'(63'(64'hFFFFFFFFFFFFFFFF));
  localparam n_65_32  = 65'(32'(64'hFFFFFFFFFFFFFFFF));
  localparam n_128_65 = 128'(65'(64'hFFFFFFFFFFFFFFFF));
  localparam n_192_128= 192'(128'(64'hFFFFFFFFFFFFFFFF));
  localparam n_65_64  = 65'(64'(64'hFFFFFFFFFFFFFFFF));
  // outer NARROWER than inner -- slang COLLAPSES the inner cast away
  localparam n_65_96  = 65'(96'(64'hFFFFFFFFFFFFFFFF));
  localparam n_32_65  = 32'(65'(64'hFFFFFFFFFFFFFFFF));
  localparam n_64_96  = 64'(96'(64'hFFFFFFFFFFFFFFFF));
  localparam n_64_65  = 64'(65'(64'hFFFFFFFFFFFFFFFF));
  localparam n_128_192= 128'(192'(64'hFFFFFFFFFFFFFFFF));
  // equal widths
  localparam n_64_64  = 64'(64'(64'hFFFFFFFFFFFFFFFF));
  localparam n_96_96  = 96'(96'(64'hFFFFFFFFFFFFFFFF));
  // three deep
  localparam n_96_65_64 = 96'(65'(64'(64'hFFFFFFFFFFFFFFFF)));
  localparam n_128_96_65= 128'(96'(65'(64'hFFFFFFFFFFFFFFFF)));
  // a chain over a parameter read
  localparam n_96_65_p  = 96'(65'(A));
  // the 32..63 CONTROL BAND: no cast in the chain reaches 64
  localparam n_32_16    = 32'(16'(64'hFFFFFFFFFFFFFFFF));
  localparam n_63_32    = 63'(32'(64'hFFFFFFFFFFFFFFFF));
  localparam n_48_63    = 48'(63'(64'hFFFFFFFFFFFFFFFF));
endmodule
