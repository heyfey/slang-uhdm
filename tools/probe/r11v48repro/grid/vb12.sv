// vb12 — a TYPEDEF'd `int` and a typedef'd `int unsigned` localparam bound.
module vb12 (input logic c, output logic o);
  typedef int          mi_t;
  typedef int unsigned mu_t;
  localparam mi_t PS = 4;
  localparam mu_t PU = 4;
  logic [PS:0] xs;
  logic [PU:0] xu;
  assign o = c ^ xs[0] ^ xu[0];
endmodule
