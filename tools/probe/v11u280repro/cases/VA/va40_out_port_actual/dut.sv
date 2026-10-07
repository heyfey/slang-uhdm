// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// member multi-selects as an output port actual (an lvalue) and an input actual of an instance array
module kid(input logic a, output logic o); assign o = a; endmodule
module top(input logic [1:0] k, input logic d, output logic p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  kid u (.a(d), .o(z.g[1][0]));
  kid ua [1:0] (.a({z.g[k][1], z.g[k][0]}), .o());
  assign p = z.b;
endmodule
