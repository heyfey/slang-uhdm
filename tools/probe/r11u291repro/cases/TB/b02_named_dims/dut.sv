// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [5:0] a, output logic o);
  child #(.T(pk::w_t [1:0])) u (.a(a), .o(o));
endmodule
