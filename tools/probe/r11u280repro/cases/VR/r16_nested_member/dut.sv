// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member path two members deep then two selects
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; } i_t;
  typedef struct packed { i_t in; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.in.g[k][1];
endmodule
