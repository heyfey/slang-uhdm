// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  property p; @(posedge clk) a |-> b; endproperty
  cp: cover property (p);
endmodule
