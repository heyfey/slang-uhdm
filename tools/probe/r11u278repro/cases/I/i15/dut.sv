// § ifaceElabTypeParamIsDefObj278
interface inner #(parameter type T = logic [1:0]) ();
  logic [1:0] x;
endinterface
interface outer ();
  inner i();
endinterface
module top; outer o(); endmodule
