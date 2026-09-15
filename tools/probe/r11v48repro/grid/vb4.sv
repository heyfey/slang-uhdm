// vb4 — the we24 2x2: one instance overridden, one at DEFAULT, signed int.
module vb4sub #(parameter int P = 4) (input logic c, output logic o);
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
module vb4 (input logic c, output logic o1, output logic o2);
  vb4sub #(.P(8)) u1 (.c(c), .o(o1));
  vb4sub          u2 (.c(c), .o(o2));
endmodule
