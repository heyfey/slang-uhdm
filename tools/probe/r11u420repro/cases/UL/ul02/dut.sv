// § unitVarNetSourceOrder420
string label = "L";
module top;
  logic clk, a;
  initial $display(label);
  property prop;
    int x;
    @(posedge clk) (a, x = 1) |-> ##1 (a == x);
  endproperty
  assert property (prop);
endmodule
