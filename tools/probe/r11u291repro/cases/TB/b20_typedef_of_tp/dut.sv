// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic) (input logic [2:0] a, output logic o);
  typedef T t2;
  t2 v;
  assign v = a;
  assign o = ^v;
endmodule
module dut (input logic [2:0] a, output logic o);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
endmodule
