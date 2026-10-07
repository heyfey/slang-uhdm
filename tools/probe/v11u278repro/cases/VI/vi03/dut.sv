// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter int W = 2, parameter type T = logic [W-1:0]) ();
  T v;
  assign v = '1;
endinterface
module top(output logic [7:0] o, output logic [7:0] o2);
  ifc u1();
  ifc #(.W(5)) u2();
  assign o = u1.v;
  assign o2 = u2.v;
endmodule
