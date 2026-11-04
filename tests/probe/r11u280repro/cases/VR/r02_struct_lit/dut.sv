// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue struct member two literal selects
module top(output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[2][0];
endmodule
