// § assertBinParenSpanInner420
module top;
  logic clk, a, b, c, d;
  assert property (@(posedge clk) ((a ##1 b) and (c ##1 d)));
endmodule
