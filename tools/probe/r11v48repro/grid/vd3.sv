// vd3 — a THREE-HOP derivation chain with mixed signing tokens.
module vd3 (input logic c, output logic o);
  localparam int          A = 4;
  localparam int unsigned B = A;
  localparam int unsigned C = B;
  localparam int unsigned D = 4;
  localparam int unsigned E = D;
  logic [C:0] xc;
  logic [E:0] xe;
  assign o = c ^ xc[0] ^ xe[0];
endmodule
