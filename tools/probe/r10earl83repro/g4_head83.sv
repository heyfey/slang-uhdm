// r10earl83 arm 4 — THE HEAD, MINIMISED.  `flash_ctrl.sv:137`'s shape and
// nothing else: a size cast whose width is a parameter name, over an unbased
// decimal literal, as an ELABORATED port High_conn actual.  PRISTINE fails the
// official uhdm-cmp on this file; PATCHED passes it.
module ch4_83 (input logic [31:0] rdata_i, output logic [31:0] y);
  assign y = ~rdata_i;
endmodule

module g4_head83;
  localparam int BusWidth = 32;
  logic [31:0] y0;
  ch4_83 u_c (.rdata_i (BusWidth'(0)), .y (y0));
endmodule
