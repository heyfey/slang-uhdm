// § unitVarNetSourceOrder420
string label = "L";
module top;
  logic clk, a;
  property prop;
    int x;
    @(posedge clk) (a, x = 1) |-> ##1 (a == x);
  endproperty
  always @(posedge clk) $display(label);
  initial $display(label);
endmodule
