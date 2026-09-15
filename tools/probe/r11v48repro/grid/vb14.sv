// vb14 — TWO packed dims, signed x unsigned, and a 2-D mixed pair.
module vb14 (input logic c, output logic o);
  localparam int          PS = 3;
  localparam int unsigned PU = 3;
  logic [PS:0][PU:0] m;
  logic [PU:0][PS:0] n;
  assign o = c ^ m[0][0] ^ n[0][0];
endmodule
