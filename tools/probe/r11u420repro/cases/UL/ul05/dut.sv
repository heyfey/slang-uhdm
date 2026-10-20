// § unitVarNetSourceOrder420
string label = "L";
module top;
  logic clk, a;
  sequence s;
    int x;
    @(posedge clk) (a, x = 1) ##1 (a == x);
  endsequence
  assert property (s) else $display(label);
endmodule
