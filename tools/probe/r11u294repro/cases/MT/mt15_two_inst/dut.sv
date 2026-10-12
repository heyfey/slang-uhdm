// § castModTypeParamDefaultTs294
// the module instantiated twice without overrides
module sub #(parameter int W = 4, parameter type T = logic [W-1:0]) (input logic [3:0] a, output logic [3:0] y);
  assign y = T'(a);
endmodule
module top(input logic [3:0] a, output logic [3:0] y1, y2);
  sub u1 (.a(a), .y(y1));
  sub u2 (.a(a), .y(y2));
endmodule
