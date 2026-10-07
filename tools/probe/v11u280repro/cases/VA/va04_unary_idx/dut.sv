// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// unary and binary operations over a reference in the index
module top(input logic [1:0] k, output logic o, output logic p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[~k][1];
  assign p = z.g[k + 2'd1][k[0]];
endmodule
