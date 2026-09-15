// vb5 — implicit type with SIGNING TOKEN only.
module vb5 (input logic c, output logic o);
  localparam signed P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
