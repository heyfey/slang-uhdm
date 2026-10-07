// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// lvalue member two selects (unchanged arm) beside an rvalue
module top(input logic [1:0] k, input logic d, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  always_comb begin
    z = '0;
    z.g[k][1] = d;
  end
  assign o = z.g[k][1];
endmodule
