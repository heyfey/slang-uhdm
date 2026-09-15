// h6 — h2 with DEPTH=4 so the ternary takes the $clog2 ARM, not the literal.
module h6 #(parameter int unsigned DEPTH = 4) (input logic c, output logic o);
  localparam int unsigned P = (DEPTH > 1) ? $clog2(DEPTH) : 1;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
