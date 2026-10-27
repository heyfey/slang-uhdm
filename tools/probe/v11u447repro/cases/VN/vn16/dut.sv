// § nestedProcEnumValAbstain447v
module m #(parameter P) (input clk);
  wire w;
  initial begin : b enum logic [1:0] {LA = 2'd2, LB} e; e = LA; end
  assign w = LB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
