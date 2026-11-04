// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a concatenation left side holding member multi-selects and an rvalue in a compound assignment
module top(input logic [1:0] k, input logic [1:0] d, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  always_comb begin
    z = '0;
    {z.g[k][1], z.g[k][0]} = d;
    z.b |= z.g[k][1];
  end
  assign o = z.b;
endmodule
