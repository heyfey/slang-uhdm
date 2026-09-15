// vb11 — a PACKAGE-QUALIFIED bound, signed and unsigned.
package vb11p;
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
endpackage
module vb11 (input logic c, output logic o);
  logic [vb11p::PS:0] xs;
  logic [vb11p::PU:0] xu;
  assign o = c ^ xs[0] ^ xu[0];
endmodule
