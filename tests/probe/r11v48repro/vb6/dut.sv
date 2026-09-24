// vb6 — `bit signed [7:0]`: bit_typespec IS in valueRange's switch.
module vb6 (input logic c, output logic o);
  localparam bit signed [7:0] P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
