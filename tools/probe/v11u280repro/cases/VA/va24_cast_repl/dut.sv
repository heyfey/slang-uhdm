// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the path under a cast, a replication and an assignment pattern
module top(input logic [1:0] k, output logic [3:0] o, output logic [1:0] p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  typedef struct packed { logic a; logic c; } t_t;
  s_t z;
  t_t t;
  assign z = '0;
  assign o = {2{2'(z.g[k][1])}};
  assign t = '{a: z.g[k][1], c: z.g[k][0]};
  assign p = t;
endmodule
