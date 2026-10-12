// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module unused #(parameter type T = pk::w_t) (input T a, output logic o);
  T v;
  assign v = a;
  assign o = ^v;
endmodule
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [2:0] a, output logic o, output logic p);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
  unused u2 (.a(a), .o(p));
endmodule
