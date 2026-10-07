// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects, a call inside an index (abstains)
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  function automatic logic [1:0] gi(logic [1:0] x); return x; endfunction
  s_t z;
  assign z = '0;
  assign o = z.g[gi(k)][1];
endmodule
