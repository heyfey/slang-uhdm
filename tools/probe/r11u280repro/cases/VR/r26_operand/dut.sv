// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects as an operand, a ternary branch and a concatenation member
module top(input logic [1:0] k, input logic c, output logic o, output logic [1:0] q);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = c ? z.g[k][1] : ~z.g[k][0];
  assign q = {z.g[k][1], z.g[k + 1][0]};
endmodule
