// § castModTypeParamDefaultTs294
// a cast in a program with a type parameter
program p #(parameter type T = logic [2:0]) (input logic [3:0] a);
  T y;
  initial y = T'(a);
endprogram
module top(input logic [3:0] a); p p0 (.a(a)); endmodule
