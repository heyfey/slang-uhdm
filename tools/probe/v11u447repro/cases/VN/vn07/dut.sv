// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  function automatic int f(); enum {FA, FB} q; return FB; endfunction
  assign w = FA | FB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
