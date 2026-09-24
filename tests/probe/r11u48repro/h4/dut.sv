// h4 — h2 with signed `int`: isolates SIGNEDNESS the other way.
module h4 #(parameter int DEPTH = 1) (input logic c, output logic o);
  localparam int P = (DEPTH > 1) ? $clog2(DEPTH) : 1;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
