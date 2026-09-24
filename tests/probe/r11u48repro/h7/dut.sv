// h7 — the ternary with NO $clog2 at all, literal arms only.
module h7 #(parameter int unsigned DEPTH = 1) (input logic c, output logic o);
  localparam int unsigned P = (DEPTH > 1) ? 2 : 1;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
