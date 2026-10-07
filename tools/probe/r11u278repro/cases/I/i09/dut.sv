// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0]) ();
  logic [1:0] x;
endinterface
module m (ifc p); endmodule
module top; ifc u(); m mm(.p(u)); endmodule
