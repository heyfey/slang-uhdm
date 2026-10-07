// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// member paths whose last select is a part select or an indexed part select after an element select
module top(input logic [1:0] k, output logic [1:0] o, output logic [1:0] p);
  typedef struct packed { logic [3:0][3:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[k][1:0];
  assign p = z.g[k][1 +: 2];
endmodule
