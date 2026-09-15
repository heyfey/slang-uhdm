// vd1 — an IMPORTED package localparam read BARE as a bound, signed x unsigned.
package vd1p;
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
endpackage
module vd1 (input logic c, output logic o);
  import vd1p::*;
  logic [PS:0] xs;
  logic [PU:0] xu;
  assign o = c ^ xs[0] ^ xu[0];
endmodule
