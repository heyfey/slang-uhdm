// § undefaultedDefInvalidInst404
`define INV(p) p
module fifo #(parameter `INV(lg_size_p), parameter `INV(width_p), parameter ctl_p = 0)
  (input clk, input [width_p-1:0] d, output [width_p-1:0] q, output [lg_size_p:0] cnt);
  localparam size_lp = 1 << lg_size_p;
  logic [width_p-1:0] mem [size_lp-1:0];
  assign q = mem[0];
  assign cnt = '0;
endmodule
module fifo__abstract(); if (0) begin : abstract fifo not_used(); end endmodule
module top; endmodule
