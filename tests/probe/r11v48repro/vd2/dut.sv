// vd2 — an EXPRESSION bound (`[P-1:0]`), signed x unsigned: not a bare ref.
module vd2 (input logic c, output logic o);
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
  logic [PS-1:0] xs;
  logic [PU-1:0] xu;
  assign o = c ^ xs[0] ^ xu[0];
endmodule
