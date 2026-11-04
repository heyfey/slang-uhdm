package vp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  logic en;
  logic [7:0] data;
  s_t st;
  logic [7:0] arr [4];
endpackage
module top (input logic clk, output logic [7:0] q);
  always_ff @(posedge clk) if (vp :: en) q <= vp :: data;
endmodule
