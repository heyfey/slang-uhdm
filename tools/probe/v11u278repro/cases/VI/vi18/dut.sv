// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [3:0]) ();
  T v;
  assign v = 4'h5;
endinterface
module top(output logic [3:0] o);
  if (1) begin : g
    ifc u();
  end
  assign o = g.u.v;
endmodule
