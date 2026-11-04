// § pasteChainRunning160v
`define TRI(a, b) a``_``b[0]
module top (output logic o);
  logic [1:0] u_v;
  assign u_v = 2'b01;
  assign o = `TRI(u, v) | 1'b0;
endmodule
