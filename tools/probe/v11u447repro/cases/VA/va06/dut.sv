// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  function automatic void f(); enum {UX, UY} e; endfunction
  assign w = UX;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
