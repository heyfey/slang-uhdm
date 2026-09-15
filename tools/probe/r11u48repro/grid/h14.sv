// h14 — an UNSIGNED logic vector: in the switch, VpiSigned false.
module h14 (input logic c, output logic o);
  localparam logic [7:0] P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
