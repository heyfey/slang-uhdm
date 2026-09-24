// h18 — the signed twin of h17.
localparam int US = 4;
module h18 (input logic c, output logic o);
  logic [US:0] x;
  assign o = c ^ x[0];
endmodule
