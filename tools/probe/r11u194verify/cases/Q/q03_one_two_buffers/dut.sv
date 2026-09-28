// § macroPathTokSpans183 § macroPathTokOneBuffer186: a member path whose select is written wholly in the macro body (one buffer) beside one whose select bounds are macro arguments (two buffers), in a generate scope and at module level
`define BODY_SEL(IF) assign IF.lo = IF.w[3:0];
`define ARG_SEL(IF, L, W) assign IF.hi = IF.w[L +: W];
interface wif;
  logic [7:0] w;
  logic [3:0] lo;
  logic [3:0] hi;
endinterface
module m (wif p);
  `BODY_SEL(p)
  if (1) begin : g
    `ARG_SEL(p, 4, 4)
  end
endmodule
module top;
  wif w ();
  m u (.p(w));
endmodule
