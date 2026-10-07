// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects inside a module function
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  function automatic logic f(s_t a, logic [1:0] i);
    return a.g[i][1];
  endfunction
  s_t z;
  assign z = '0;
  assign o = f(z, k);
endmodule
