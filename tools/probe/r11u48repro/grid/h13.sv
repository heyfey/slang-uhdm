// h13 — a SIGNED logic vector: logic_typespec IS in the switch.
module h13 (input logic c, output logic o);
  localparam logic signed [7:0] P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
