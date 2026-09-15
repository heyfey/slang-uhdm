// h2 — packed_struct_array_fifo shape: `int unsigned` localparam folded from a
// ternary whose DEFAULT arm is the bare literal.  THE HEAD.
module h2 #(parameter int unsigned DEPTH = 1) (input logic c, output logic o);
  localparam int unsigned P = (DEPTH > 1) ? $clog2(DEPTH) : 1;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
