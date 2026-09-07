package vpg;
  parameter G_RADIX   = 'hf000000;
  parameter G_DEFAULT = 'b000000101010101;
  parameter G_ALL_ON  = 'b000000000111111;
  parameter G_FLAGS   = 'b111111111111111;
  parameter int G_KEEP_INT = 5;
  parameter string G_KEEP_STR = "keep";
  parameter G_SET = 6;
  parameter G_SETINT = G_SET;
endpackage
import vpg::*;
module vg(input logic clk);
  logic q;
  always_ff @(posedge clk) q <= 1'b0;
endmodule
