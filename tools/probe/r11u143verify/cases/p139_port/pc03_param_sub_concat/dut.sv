// § connLeftmostLeafElab139
// case pc03: a concatenation actual on a parameterized sub-module with an override
module sub #(parameter int W = 1) (input logic [W-1:0] a, output logic [W-1:0] y); assign y = a; endmodule
module top(input logic p, input logic q, output logic [1:0] y);
  sub #(.W(2)) u(.a({p, q}), .y(y));
endmodule
