// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a signed system call, $clog2 and a cast inside the index
module top(input logic [1:0] k, output logic o, output logic p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[$unsigned(k)][1];
  assign p = z.g[2'(k)][$clog2(2)];
endmodule
