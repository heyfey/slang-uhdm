// § tpVarInitSizedByDefault424
module ma #(parameter type p2 = logic [3:0]) (input logic i);
  p2 j = 5;
endmodule
module top; logic i; ma #(.p2(logic [7:0])) u1(i); endmodule
