// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [3:0]) ();
  T v;
  modport mp(output v);
endinterface
module drv(ifc.mp b); assign b.v = 4'hA; endmodule
module top(output logic [3:0] o);
  ifc u();
  drv d(.b(u));
  assign o = u.v;
endmodule
