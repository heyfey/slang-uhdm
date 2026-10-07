// § ifaceTpOvrTpRefAbstain278v
interface ifc #(parameter type T = logic [1:0]) ();
  localparam type U = T [1:0];
  logic [1:0] x;
endinterface
module top; ifc #(.T(logic [3:0])) u(); endmodule
