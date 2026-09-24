// h16 — the mirror of h15: a SIGNED `int` localparam initialised from an
// `int unsigned` one.
module h16 (input logic c, output logic o);
  localparam int unsigned Q = 4;
  localparam int P = Q;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
