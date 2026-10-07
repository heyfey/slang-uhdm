// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = int) ();
  T v;
  assign v = -3;
endinterface
module top(output logic [31:0] o);
  ifc u();
  assign o = u.v;
endmodule
