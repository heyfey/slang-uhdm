// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter int W = 2, parameter type T = logic [W-1:0]) ();
  logic [1:0] x;
endinterface
module top; ifc u(); endmodule
