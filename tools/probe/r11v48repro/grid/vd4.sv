// vd4 — an ENUM-typed and a REAL-derived localparam bound.
module vd4 (input logic c, output logic o);
  typedef enum int { E0 = 0, E4 = 4 } e_t;
  localparam e_t PE = E4;
  localparam int PI = int'(4.0);
  logic [PE:0] xe;
  logic [PI:0] xi;
  assign o = c ^ xe[0] ^ xi[0];
endmodule
