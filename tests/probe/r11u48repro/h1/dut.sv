// h1 — issue326 shape: signed `int` localparam folded from $clog2.  POSITIVE.
module h1 #(parameter int DEPTH = 16) (input logic c, output logic o);
  localparam int P = $clog2(DEPTH);
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
