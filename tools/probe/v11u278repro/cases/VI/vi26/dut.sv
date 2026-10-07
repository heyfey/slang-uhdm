// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0], parameter type U = T) ();
  localparam type V = U [1:0];
  logic [1:0] x;
endinterface
module top; ifc #(.T(logic [3:0])) u(); endmodule
