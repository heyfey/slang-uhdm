// h3 — h1 with `int unsigned`: isolates SIGNEDNESS.
module h3 #(parameter int DEPTH = 16) (input logic c, output logic o);
  localparam int unsigned P = $clog2(DEPTH);
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
