// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [1:0]) ();
  logic [1:0] x;
endinterface
module top; if (1) begin : g ifc u(); end endmodule
