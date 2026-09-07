package vpm;
  parameter M_W    = 'h8;
  parameter M_WDEC = 8;
  parameter logic [31:0] M_VAL  = M_W + 1;
  parameter logic [31:0] M_VAL2 = M_WDEC + 1;
endpackage
import vpm::*;
module vm(input logic clk);
  logic [31:0] q;
  always_ff @(posedge clk) q <= M_VAL;
endmodule
