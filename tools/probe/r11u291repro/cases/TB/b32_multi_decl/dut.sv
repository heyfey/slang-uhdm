// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic) (input logic [2:0] a, output logic o);
  T v1, v2;
  assign v1 = a;
  assign v2 = ~a;
  assign o = ^(v1 ^ v2);
endmodule
module dut (input logic [2:0] a, output logic o);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
endmodule
