// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// rvalue member two selects as a port actual
module kid(input logic a, output logic o); assign o = a; endmodule
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  kid u (.a(z.g[k][1]), .o(o));
endmodule
