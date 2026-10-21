// § tpVarInitSizedByDefault424 (control: no override)
module ma #(parameter type p2 = shortint) (input logic i);
  p2 j = 0;
endmodule
module top; logic i; ma u1(i); endmodule
