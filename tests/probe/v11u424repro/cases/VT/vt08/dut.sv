// § tpVarInitSizedByDefault424
module ma #(parameter type T = shortint) (input logic i);
  T j = 2;
endmodule
module top; logic i; ma #(.T(logic [31:0])) u1(i); ma #(.T(byte)) u2(i); endmodule
