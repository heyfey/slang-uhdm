// v55 adversarial arm 8 — the RANGED-UNTYPED declaration form.  The enclosing
// guard is `(typedParam || rangedFold)`, and every arm so far exercised
// typedParam only: `localparam [0:0] X = {1{1'b1}}` has NO type keyword, so it
// reaches the SAME PackedArrayType arm through the OTHER half of the guard and
// the width-1 branch fires on it too.  Also: `signed`, multi-dim and a plain
// unranged untyped param (which must NOT reach the arm at all).
// MEASURED (both views, both binaries): TO-GOLDEN 4 / AWAY-GOLDEN 0 /
// STILL-WRONG 0.  `localparam [0:0]`, `localparam signed [0:0]` and
// `localparam [0:0][0:0]` all reach the arm through the rangedFold half of the
// guard and all land on golden; the unranged untyped param still takes the
// pre-existing § replFoldTs9 path and agrees; the [1:0] control is unchanged
// and remains R1.
module v8_v55(input logic ext);
  w0_v55 u_w0 (.o(), .ext(ext));
  w1_v55 u_w1 (.o(), .ext(ext));
endmodule

module w0_v55 (output logic o, input logic ext);
  localparam [0:0]        RU  = {1{1'b1}};   // ranged, untyped, width 1
  localparam signed [0:0] RS  = {1{1'b1}};   // ranged signed, untyped, width 1
  localparam [0:0][0:0]   RM  = {1{1'b1}};   // multidim, width 1
  localparam [1:0]        R2  = {2{1'b1}};   // ranged, untyped, width 2 control
  assign o = ext;
endmodule

module w1_v55 (output logic o, input logic ext);
  localparam UN = {1{1'b1}};                  // untyped UNRANGED (replFoldTs9)
  localparam [0:0] RC = {1{1'b1}};
  assign o = ext ^ RC[0] ^ UN[0];
endmodule
