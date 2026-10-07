// § ifaceElabTypeParamIsDefObj278
interface inner #(parameter int W = 2, parameter type T = logic [W-1:0]) ();
  T v;
  assign v = '1;
endinterface
interface outer ();
  inner #(.W(5)) i();
endinterface
module top(output logic [7:0] o);
  outer ou();
  assign o = ou.i.v;
endmodule
