// § pasteChainRunning160v
`define A(n) arr_``n[1] & 1'b1
module top (input logic [3:0] arr_xy, output logic y, output logic z);
  assign y = `A(xy); assign z = arr_xy[0];
endmodule
