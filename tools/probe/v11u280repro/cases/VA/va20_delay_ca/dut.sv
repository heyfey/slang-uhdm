// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a continuous assignment with a delay and a net declaration assignment
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  wire w = z.g[k][1];
  assign #1 o = z.g[k][0] | w;
endmodule
