// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
program prg #(parameter type T = logic) (input logic [2:0] a);
  T v;
  initial v = a;
endprogram
module dut (input logic [2:0] a);
  prg #(.T(pk::w_t)) p (.a(a));
endmodule
