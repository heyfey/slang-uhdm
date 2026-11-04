// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic) (input T a, output T o);
  assign o = a;
endmodule
module dut (input logic [2:0] a, output logic [2:0] o);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
endmodule
