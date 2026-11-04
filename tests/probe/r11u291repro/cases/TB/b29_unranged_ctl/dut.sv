// § tpUseSigBindsTpObj291
package pk; typedef logic b1_t; endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  T v;
  assign v = a;
  assign o = v;
endmodule
module dut (input logic a, output logic o);
  child #(.T(pk::b1_t)) u (.a(a), .o(o));
endmodule
