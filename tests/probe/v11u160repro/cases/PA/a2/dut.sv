// § pasteChainRunning160v
`define A(n) arr_``n[1]
module top (input logic [3:0] arr_x, output logic y, output logic z);
  assign y = `A(x); assign z = arr_x[0];
endmodule
