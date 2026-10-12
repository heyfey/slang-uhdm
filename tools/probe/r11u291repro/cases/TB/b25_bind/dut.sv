// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module chk #(parameter type T = logic) (input logic [2:0] a);
  T v;
  assign v = a;
endmodule
module dut (input logic [2:0] a, output logic o);
  assign o = ^a;
endmodule
bind dut chk #(.T(pk::w_t)) c (.a(a));
