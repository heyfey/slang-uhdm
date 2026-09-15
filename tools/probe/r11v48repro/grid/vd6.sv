// vd6 — a signed and an unsigned bound in a PACKAGE-scope typedef.
package vd6p;
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
  typedef logic [PS:0] ts_t;
  typedef logic [PU:0] tu_t;
endpackage
module vd6 (input logic c, output logic o);
  vd6p::ts_t xs;
  vd6p::tu_t xu;
  assign o = c ^ xs[0] ^ xu[0];
endmodule
