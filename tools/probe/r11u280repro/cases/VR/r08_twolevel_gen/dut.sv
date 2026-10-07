// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// rvalue member two selects two generate levels down, in a process
module top(input logic [1:0] k, output logic [3:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  for (genvar i = 0; i < 2; i++) begin : ga
    for (genvar j = 0; j < 2; j++) begin : gb
      always_comb o[2*i+j] = z.g[k][j];
    end
  end
endmodule
