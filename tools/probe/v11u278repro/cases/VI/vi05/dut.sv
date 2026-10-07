// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter int W = 2, parameter type T = logic [W-1:0]) ();
  T v;
  assign v = '1;
endinterface
module top(output logic [7:0] o0, output logic [7:0] o1);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc #(.W(i+3)) u();
  end
  assign o0 = g[0].u.v;
  assign o1 = g[1].u.v;
endmodule
