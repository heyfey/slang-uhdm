// § castModTypeParamDefaultTs294
// a cast in a localparam initializer and a header parameter (constant slots)
module top #(parameter type T = logic [3:0], parameter T P = T'(5)) (output logic [3:0] y, z);
  localparam T Q = T'(7);
  localparam int R = $bits(T'(1));
  assign y = P ^ Q;
  assign z = R;
endmodule
