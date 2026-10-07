// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter int W = 2, parameter type T = logic [W-1:0]) ();
  T v;
  assign v = '1;
endinterface
module top(output logic [7:0] o);
  ifc #(.W(3)) u [2] ();
  assign o = {u[0].v, u[1].v};
endmodule
