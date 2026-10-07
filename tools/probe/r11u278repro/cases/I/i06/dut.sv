// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0]) ();
  logic [1:0] x;
endinterface
module top; ifc u1(); ifc u2(); endmodule
