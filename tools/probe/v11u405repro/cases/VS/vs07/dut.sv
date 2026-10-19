// § undefParamCastSizeTs405
module top; endmodule
interface ifc #(parameter w) ();
  logic [7:0] a, b;
  assign b = w'(a);
endinterface
module m__abstract(); if (0) begin : abstract ifc not_used(); end endmodule
