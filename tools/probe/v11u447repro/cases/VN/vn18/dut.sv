// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  task automatic t(); enum {KA, KB} k; k = KA; endtask
  assign w = KB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
