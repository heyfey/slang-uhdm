// § castModTypeParamDefaultTs294
// an instance overriding the type
module sub #(parameter type T = logic [7:0]) (input logic [3:0] a, output logic [7:0] y);
  always_comb y = T'(a);
endmodule
module top(input logic [3:0] a, output logic [7:0] y1, y2);
  sub u1 (.a(a), .y(y1));
  sub #(.T(logic [5:0])) u2 (.a(a), .y(y2));
endmodule
