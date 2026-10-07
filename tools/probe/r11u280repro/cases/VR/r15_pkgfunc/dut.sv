// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects inside a package function
package pq;
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  function automatic logic f(s_t a, logic [1:0] i);
    logic r;
    r = a.g[i][1];
    return r;
  endfunction
endpackage
module top(input logic [1:0] k, output logic o);
  pq::s_t z;
  assign z = '0;
  assign o = pq::f(z, k);
endmodule
