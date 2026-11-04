// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module dut #(parameter type T = pk::w_t) (input T a, output logic o);
  T v;
  assign v = a;
  assign o = ^v;
endmodule
