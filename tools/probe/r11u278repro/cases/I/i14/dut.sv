// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0]) ();
  logic [1:0] x;
  modport mp (input x);
endinterface
module m (ifc.mp p); endmodule
module top; ifc u(); m mm(.p(u.mp)); endmodule
