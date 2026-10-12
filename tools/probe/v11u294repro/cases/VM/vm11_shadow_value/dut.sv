// § castModTypeParamDefaultTs294
// a value parameter and a type parameter cast side by side, and a cast in a select bound
module top #(parameter int W = 3, parameter type T = logic [W:0]) (input logic [7:0] a, output logic [7:0] y, z);
  assign y = W'(a) + T'(a);
  assign z = a[T'(2) +: 2];
endmodule
