// vb2 — a TOP-LEVEL `parameter int` never overridden.
module vb2 #(parameter int P = 4) (input logic c, output logic o);
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
