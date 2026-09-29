// § genScopeRangeQueryFold216 + § ndaRangeQueryFold216 — the whole generate block written by a macro, the net declared in an included header
`include "q09.svh"
`define GEN_Q(NM, SIG) for (genvar k = 0; k < 1; k++) begin : NM assign o1 = $high(SIG); end
`define NQ(SIG) $low(SIG)
module dut (output logic [7:0] o1, output logic [7:0] o2);
  `DECL_V
  `GEN_Q(gq, hv)
  wire [7:0] n = `NQ(hv);
  assign o2 = n;
endmodule
