// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  if (1) begin : g function automatic int gf(); enum {GA, GB} q; return 0; endfunction end
  assign w = GB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
