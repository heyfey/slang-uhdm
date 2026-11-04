// § castModTypeParamDefaultTs294
// a cast and a port sharing the type parameter
module top #(parameter type T = logic [3:0]) (input T a, output T y);
  assign y = T'(a + 1'b1);
endmodule
