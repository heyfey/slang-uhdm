// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  function automatic int f(); typedef enum {TA, TB} t_e; t_e v; v = TB; return v; endfunction
  assign w = TB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
