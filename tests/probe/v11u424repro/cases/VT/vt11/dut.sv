// § tpVarInitSizedByDefault424
module ma #(parameter type T = shortint) (input logic i);
  T j = 3;
endmodule
module mid; logic i; ma #(.T(int)) u(i); endmodule
module top; mid m1(); mid m2(); logic i; ma u3(i); endmodule
