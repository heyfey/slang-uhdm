// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0], parameter type U = T) ();
  logic [1:0] x;
endinterface
module top; ifc u(); endmodule
