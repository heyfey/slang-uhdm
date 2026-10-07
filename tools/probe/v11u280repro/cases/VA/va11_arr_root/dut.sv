// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// an array element as the root and a two-member path
module top(input logic [1:0] k, output logic o, output logic p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  typedef struct packed { s_t s; logic c; } t_t;
  s_t za [2];
  t_t w;
  assign za = '{default: '0};
  assign w = '0;
  assign o = za[0].g[k][1];
  assign p = w.s.g[k][1];
endmodule
