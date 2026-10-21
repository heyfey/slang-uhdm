// § tpVarInitSizedByDefault424
module ma #(parameter type T = int, parameter type U = T) (input logic i);
  U j = 7;
endmodule
module top; logic i; ma #(.T(shortint)) u1(i); endmodule
