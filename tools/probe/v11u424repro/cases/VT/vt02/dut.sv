// § tpVarInitSizedByDefault424
module ma #(parameter type T = logic [3:0]) (input logic i);
  T j = 5;
endmodule
module top; logic i; ma #(.T(logic [7:0])) u1(i); ma u2(i); endmodule
