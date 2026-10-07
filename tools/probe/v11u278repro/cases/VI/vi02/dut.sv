// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0], parameter type U = T) ();
  U v;
  assign v = '1;
endinterface
module top(output logic [7:0] o);
  ifc #(.T(logic [5:0])) u();
  assign o = u.v;
endmodule
