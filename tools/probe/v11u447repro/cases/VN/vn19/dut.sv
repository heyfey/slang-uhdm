// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  function automatic int f(); begin : fb enum {NA, NB} n; n = NA; end return 0; endfunction
  assign w = NB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
