// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects with a parameter and a localparam index
module top #(parameter int P = 1)(output logic o);
  localparam int L = 2;
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[L][P];
endmodule
