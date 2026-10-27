// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  if (1) begin : g typedef enum {HA, HB} h_e; end
  assign w = HB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
