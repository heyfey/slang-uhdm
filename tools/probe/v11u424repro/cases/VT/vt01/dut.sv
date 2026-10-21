// § tpVarInitSizedByDefault424
module ma #(parameter type T = byte) (input logic i);
  T j = 300;
endmodule
module top; logic i; ma #(.T(int)) u1(i); endmodule
