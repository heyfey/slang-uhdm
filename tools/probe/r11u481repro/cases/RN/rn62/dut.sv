// § vifTdRefVarLocalImplicitNet481
module m #(parameter P) (input clk);
  wire w;
  initial begin : b typedef enum {DA, DB} d_e; d_e d; d = DA; end
  assign w = DB;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
