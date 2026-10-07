// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0]) ();
  logic [1:0] x;
endinterface
module m; ifc u(); endmodule
module top; m a(); m b(); endmodule
