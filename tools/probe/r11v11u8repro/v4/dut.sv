// v4 — mixed whitespace kinds: a TAB written in the body after the marker,
// reached across a SPACE continuation, and the mirror (spaces in the body,
// a TAB continuation).
`define TB(__x) `"	__x`"
`define SP(__x) `"  __x`"
`define LS(__x) $display("%0s",    \
     `TB(__x));
`define LT(__x) $display("%0s",	\
     `SP(__x));
module top;
  initial begin
    $display("%0s", `TB(tb0));
    $display("%0s", `SP(sp0));
    `LS(tbleak)
    `LT(spleak)
  end
endmodule
