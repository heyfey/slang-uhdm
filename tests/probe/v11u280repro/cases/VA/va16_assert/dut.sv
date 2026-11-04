// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the path in an immediate assertion and in a while condition
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  always_comb begin
    assert (z.g[k][1] == 1'b0);
    o = 1'b0;
    if (z.g[k][0]) o = 1'b1;
  end
endmodule
