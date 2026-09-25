// § ppMacroBodyLines160
`define ONE(x) (x + 1)
`define MK(n, v) \
  logic [3:0] sig_``n; \
  assign sig_``n = `ONE(v) + \
                   `ONE(v);
module top (input logic [3:0] a, output logic [3:0] o);
  `MK(a0, a) assign o = sig_a0;
endmodule
