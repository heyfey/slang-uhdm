// § tpUseSigBindsTpObj291
package pk; typedef bit [2:0] b_t; endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [2:0] a, output logic o);
  child #(.T(pk::b_t)) u (.a(a), .o(o));
endmodule
