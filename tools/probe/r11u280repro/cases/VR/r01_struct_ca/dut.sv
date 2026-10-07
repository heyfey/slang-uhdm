// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue struct member two selects in a module continuous assignment, ref + literal
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[k][1];
endmodule
