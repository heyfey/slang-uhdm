// § tpVarInitSizedByDefault424
module ma #(parameter type p2 = byte) (input logic i);
  p2 j = 300;
  p2 k;
endmodule
module top; logic i; ma #(.p2(int)) u1(i); ma u2(i); endmodule
