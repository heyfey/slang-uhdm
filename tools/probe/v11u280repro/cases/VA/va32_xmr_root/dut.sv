// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a hierarchical reference into a child instance's struct with two selects
module kid(output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.b;
endmodule
module top(input logic [1:0] k, output logic o, output logic p);
  kid u (.o(p));
  assign o = u.z.g[k][1];
endmodule
