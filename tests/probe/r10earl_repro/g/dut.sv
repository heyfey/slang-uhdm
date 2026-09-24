package tp;
  parameter int TL_AW = 32;
endpackage

module m1 #(
  parameter int W = 8,
  parameter logic [W-1:0]         PLocal = 'h0,
  parameter logic [tp::TL_AW-1:0] PQual  = 'h0,
  parameter logic [31:0]          PLit   = 'h0
) (
  input clk_i
);
  localparam int LW = 4;
  logic [LW-1:0] sig;
endmodule
