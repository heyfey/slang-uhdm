// vb15 — the we24 2x2 on an UNPACKED dimension (the OTHER paramValueSigned89
// call site): pre-existing behaviour, measured for comparison with vb4.
module vb15sub #(parameter int P = 4) (input logic c, output logic o);
  logic x [P];
  assign o = c ^ x[0];
endmodule
module vb15 (input logic c, output logic o1, output logic o2);
  vb15sub #(.P(8)) u1 (.c(c), .o(o1));
  vb15sub          u2 (.c(c), .o(o2));
endmodule
