// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a $unit-scope struct variable as the root
typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
s_t uz;
module top(input logic [1:0] k, output logic o);
  assign o = uz.g[k][1];
endmodule
