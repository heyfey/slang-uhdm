// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the index written by a macro from an included header
`include "m.svh"
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[`IDX(k)][1];
endmodule
