// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a program block and an interface-typed module-local path
program prg(input logic [1:0] k);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  logic o;
  initial begin z = '0; o = z.g[k][1]; end
endprogram
module top(input logic [1:0] k); prg p(.k(k)); endmodule
