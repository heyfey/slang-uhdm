// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = pk::w_t) (input logic [2:0] a, output logic o);
  T v;
  assign v = a;
  assign o = ^v;
endmodule
module dut (input logic [2:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
