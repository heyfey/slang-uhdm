// § tpVarInitSizedByDefault424
module ma #(parameter type T = int) (input logic i);
  T j = 3;
  T k = 4'd3;
  T m = '1;
endmodule
module top; logic i; ma #(.T(logic [39:0])) u1(i); endmodule
