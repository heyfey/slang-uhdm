// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module leaf #(parameter type T = logic) (input T a, output logic o);
  T v;
  assign v = a;
  assign o = ^v;
endmodule
module mid #(parameter type T = logic) (input T a, output logic o);
  T m;
  assign m = a;
  leaf #(.T(pk::w_t)) l (.a(m), .o(o));
endmodule
module dut (input logic [2:0] a, output logic o);
  mid #(.T(pk::w_t)) u (.a(a), .o(o));
endmodule
