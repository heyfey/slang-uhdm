// § ifaceElabTypeParamIsDefObj278
module m #(parameter type T = logic [1:0]) ();
  logic [1:0] x;
endmodule
module top; m u(); endmodule
