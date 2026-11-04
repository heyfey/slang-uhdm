// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; typedef logic [4:0] x_t; endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [7:0] a, output logic o, output logic p);
  child #(.T(pk::w_t)) u (.a(a[2:0]), .o(o));
  child #(.T(pk::x_t)) v (.a(a[7:3]), .o(p));
endmodule
