// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  class C; enum {CA, CB} ce; endclass
  assign w = CB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
