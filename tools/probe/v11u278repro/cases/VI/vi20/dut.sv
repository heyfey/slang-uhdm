// § ifaceTpOvrTpRefAbstain278v
interface ifc #(parameter type T = logic [1:0], parameter type U = struct packed { T a; logic b; }) ();
  logic [1:0] x;
endinterface
module top; ifc #(.T(logic [3:0])) u(); endmodule
