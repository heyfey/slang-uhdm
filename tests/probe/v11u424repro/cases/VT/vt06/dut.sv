// § tpVarInitSizedByDefault424
package pk; typedef logic [5:0] w6_t; endpackage
module ma #(parameter type T = pk::w6_t) (input logic i);
  T j = 9;
endmodule
module top; logic i; ma #(.T(int)) u1(i); endmodule
