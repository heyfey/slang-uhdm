// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects, a member path inside an index (abstains)
module top(output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic [1:0] q; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[z.q][1];
endmodule
