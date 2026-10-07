// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [3:0]) ();
  T v;
  assign v = 4'h5;
endinterface
module top(output logic [3:0] o);
  ifc u();
  ifc #(.T(logic [3:0])) w();
  assign o = u.v ^ w.v;
endmodule
