// h8 — `int unsigned` literal localparam, no fold: signedness alone on h5.
module h8 (input logic c, output logic o);
  localparam int unsigned P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
