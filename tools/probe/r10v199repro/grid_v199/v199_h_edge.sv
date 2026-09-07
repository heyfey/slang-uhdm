package vph;
  parameter H_EXPR   = 'hff + 1;
  parameter H_CAT    = {'hf, 4'h1};
  parameter H_SH     = 'sh5;
  parameter H_SB     = 'sb101;
  parameter H_CAPS   = 'HFF;
  parameter H_USCORE = 'h1_2_3;
  parameter [3:0] H_RNGU = 'hf;
  parameter signed H_SGNU = 'hff;
  parameter H_NEG    = -'h5;
  parameter H_TERN   = (1) ? 'h7 : 'h8;
  parameter H_PLAIN  = 'h9;
endpackage
import vph::*;
module vh(input logic clk);
  logic q;
  always_ff @(posedge clk) q <= 1'b0;
endmodule
