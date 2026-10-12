// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = logic [1:0]);
  T d;
endinterface
module dut (input logic [3:0] a, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc #(.T(logic [3:0])) u ();
    assign u.d = a;
  end
  assign o = g[1].u.d;
endmodule
