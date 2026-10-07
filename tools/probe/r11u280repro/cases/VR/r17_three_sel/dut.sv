// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member three selects
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [1:0][3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[1][k][0];
endmodule
