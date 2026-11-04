// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the path in an event control and a wait statement
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  always @(z.g[k][1]) o = z.g[k][0];
  initial wait (z.g[k][1]) o = 1'b0;
endmodule
