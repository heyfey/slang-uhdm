// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0]) (input T a);
  logic [1:0] x;
endinterface
module top; logic [1:0] w; ifc u(.a(w)); endmodule
