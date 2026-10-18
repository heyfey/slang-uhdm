// § macroArgParamOrder404
`define INV(p) p
module fifo #(parameter `INV(lg_size_p), parameter `INV(width_p), parameter ctl_p = 0)
  (input clk, input [width_p-1:0] d, output [width_p-1:0] q);
  localparam size_lp = 1 << lg_size_p;
  assign q = d;
endmodule
module fifo__abstract(); if (0) begin : abstract fifo not_used(); end endmodule
module top; endmodule
