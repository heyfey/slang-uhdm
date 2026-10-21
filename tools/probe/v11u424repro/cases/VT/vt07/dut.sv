// § tpVarInitSizedByDefault424
module ma #(parameter type T = shortint) (input logic i);
  if (1) begin : g
    T j = 2;
  end
  T k = -1;
endmodule
module top; logic i; ma #(.T(int)) u1(i); endmodule
