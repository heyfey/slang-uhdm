// vb16 — the we24 2x2 with an `int unsigned` parameter: golden should leave the
// DEFAULT instance bare too, so the pass's answer must be BARE on both.
module vb16sub #(parameter int unsigned P = 4) (input logic c, output logic o);
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
module vb16 (input logic c, output logic o1, output logic o2);
  vb16sub #(.P(8)) u1 (.c(c), .o(o1));
  vb16sub          u2 (.c(c), .o(o2));
endmodule
