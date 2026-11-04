// § pasteChainRunning160v
`define ACC(n) cfg_``n.x
module top (output logic [3:0] o);
  typedef struct packed { logic [3:0] x; } s_t;
  s_t cfg_a;
  assign cfg_a = '0;
  assign o = `ACC(a) + 1;
endmodule
