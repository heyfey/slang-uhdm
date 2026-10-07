// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects with a concatenation index holding a bit select
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  always_comb o = z.g[{1'b0, k[0]}][1];
endmodule
