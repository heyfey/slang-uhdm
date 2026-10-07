// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the path as a call argument, a system call argument and a ternary condition
module top(input logic [1:0] k, output logic o, output logic p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  function automatic logic f(logic a); return ~a; endfunction
  assign o = f(z.g[k][1]);
  assign p = z.g[k][0] ? 1'b1 : 1'b0;
  initial $display("%b", z.g[k][1]);
endmodule
