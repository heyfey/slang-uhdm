// § tpUseSigBindsTpObj291
package pk; typedef int unsigned u_t; endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input int unsigned a, output logic o);
  child #(.T(pk::u_t)) u (.a(a), .o(o));
endmodule
