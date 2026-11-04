// § unitVarNetSourceOrder420
string label = "L";
string other = "O";
module top;
  logic clk, a;
  initial $display(other);
  property prop;
    int x;
    @(posedge clk) (a, x = 1) |-> ##1 (a == x);
  endproperty
  assert property (prop) else $display(label);
endmodule
