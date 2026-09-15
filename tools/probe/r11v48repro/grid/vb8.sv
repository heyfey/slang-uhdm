// vb8 — the bound on the RIGHT side of the range, signed and unsigned.
module vb8 (input logic c, output logic o);
  localparam int          PS = 2;
  localparam int unsigned PU = 2;
  logic [7:PS] xs;
  logic [7:PU] xu;
  assign o = c ^ xs[7] ^ xu[7];
endmodule
