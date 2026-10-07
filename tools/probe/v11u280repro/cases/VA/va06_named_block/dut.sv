// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// inside a named begin block in an always_comb and in a for loop with local indices
module top(input logic [1:0] k, output logic [3:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  always_comb begin : blk
    for (int i = 0; i < 4; i++) o[i] = z.g[i][k[0]];
  end
endmodule
