package pk82;
  localparam int MpR = 8;
endpackage

module m82 import pk82::*; (input logic clk, output logic o);
  typedef struct packed { logic [3:0] a; } mreg_t;
  mreg_t [MpR:0] region_cfgs;
  assign o = region_cfgs[0].a[0] ^ clk;
endmodule
