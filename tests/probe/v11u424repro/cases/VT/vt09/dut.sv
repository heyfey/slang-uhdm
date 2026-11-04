// § tpVarInitSizedByDefault424
module ma #(parameter W = 4, parameter type T = logic [W-1:0]) (input logic i);
  T j = 3;
endmodule
module top; logic i; ma #(.W(8), .T(int)) u1(i); endmodule
