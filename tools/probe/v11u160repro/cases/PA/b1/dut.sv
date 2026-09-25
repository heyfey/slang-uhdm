// § pasteChainRunning160v
`define A(n) \
  assign y = arr_``n[1] & 1'b1; \
  assign z = arr_``n[0];
module top (input logic [3:0] arr_xy, output logic y, output logic z);
  `A(xy)
endmodule
