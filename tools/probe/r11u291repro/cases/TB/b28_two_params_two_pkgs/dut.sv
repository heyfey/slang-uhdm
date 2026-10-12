// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
package qk; typedef bit [1:0] w_t; endpackage
module child #(parameter type T = logic, parameter type S = logic) (input T a, input S b, output logic o);
  assign o = ^a ^ ^b;
endmodule
module dut (input logic [4:0] a, output logic o);
  child #(.T(pk::w_t), .S(qk::w_t)) u (.a(a[2:0]), .b(a[4:3]), .o(o));
endmodule
