// § ifaceTpOvrTpRefAbstain278v
interface ifc #(parameter type T = logic [1:0], parameter type U = T [1:0]) ();
  U v;
  assign v = '1;
endinterface
module top(output logic [15:0] o);
  ifc #(.T(logic [3:0])) u();
  assign o = u.v;
endmodule
