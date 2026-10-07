// § ifaceTpOvrTpRefAbstain278v
typedef logic [3:0] w_t;
interface ifc #(parameter type T = logic [1:0], parameter type U = T [1:0]) ();
  logic [1:0] x;
endinterface
module top; ifc #(.T(w_t)) u(); endmodule
