// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [3:0]) ();
  T v;
  assign v = 4'h5;
endinterface
module sub(output logic [3:0] o); ifc u(); assign o = u.v; endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
  sub a(o1);
  sub b(o2);
endmodule
