// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  initial begin : b enum {UX, UY} e; e = UY; end
  assign w = UY;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
