// § unitVarNetSourceOrder420
string label = "L";
module top;
  logic clk, a;
  property prop;
    int x;
    @(posedge clk) (a, x = 1) |-> ##1 (a == x);
  endproperty
  assert property (prop) else $display(label);
  sequence s2;
    int y;
    @(posedge clk) (a, y = 1) ##1 (a == y);
  endsequence
  cover property (s2);
endmodule
