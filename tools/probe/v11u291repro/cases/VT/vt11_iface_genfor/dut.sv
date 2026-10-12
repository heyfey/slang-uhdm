// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
interface ifc #(parameter type T = logic);
  for (genvar i = 0; i < 2; i++) begin : g
    T d;
  end
endinterface
module dut (input logic [2:0] a, output logic [2:0] o);
  ifc #(.T(pk::w_t)) u ();
  assign u.g[0].d = a;
  assign o = u.g[0].d;
endmodule
