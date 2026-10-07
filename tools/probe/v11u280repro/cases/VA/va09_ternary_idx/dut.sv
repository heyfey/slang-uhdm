// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a ternary, a part select and an unpacked element select inside the index
module top(input logic c, input logic [3:0] k, output logic o, output logic p, output logic q);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  logic [1:0] arr [4];
  assign z = '0;
  assign arr = '{default: '0};
  assign o = z.g[c ? k[1:0] : 2'd0][1];
  assign p = z.g[k[3:2]][1];
  assign q = z.g[arr[1]][0];
endmodule
