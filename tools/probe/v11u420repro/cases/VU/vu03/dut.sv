// § unitVarNetSourceOrder420
int cnt = 0;
module top(input logic clk, a);
  sequence s; int l; @(posedge clk) (a, l = cnt) ##1 l == 1; endsequence
  assert property (s);
endmodule
