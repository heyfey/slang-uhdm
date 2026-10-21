// § tpVarInitSizedByDefault424
module ma #(parameter type T = int) (input logic i);
  T j = 70000;
endmodule
module top; logic i; ma #(.T(shortint)) u1(i); endmodule
