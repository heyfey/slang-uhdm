// § unitVarNetSourceOrder420
string label = "L";
module top;
  logic clk, a;
  property prop;
    int x;
    @(posedge clk) (a, x = 1) |-> ##1 (a == x);
  endproperty
  assert property (prop) else $display(label);
  property prop2;
    int y;
    @(posedge clk) (a, y = 1) |-> ##1 (a == y);
  endproperty
  assert property (prop2);
endmodule
