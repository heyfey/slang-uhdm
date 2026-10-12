// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module leaf #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module mid #(parameter type T = logic) (input T a, output logic o);
  leaf #(.T(T)) l (.a(a), .o(o));
endmodule
module dut (input logic [2:0] a, output logic o);
  mid #(.T(pk::w_t)) m (.a(a), .o(o));
endmodule
