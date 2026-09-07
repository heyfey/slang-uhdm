package vpl;
  parameter L_W    = 'h8;
  parameter L_WDEC = 8;
  parameter logic [31:0] L_VAL  = (L_W)'(3);
  parameter logic [31:0] L_VAL2 = (L_WDEC)'(5);
endpackage
import vpl::*;
module vl(input logic clk);
  logic [31:0] q;
  always_ff @(posedge clk) q <= L_VAL;
endmodule
