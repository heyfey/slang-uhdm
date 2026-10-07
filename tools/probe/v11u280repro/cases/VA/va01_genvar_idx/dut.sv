// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// rvalue member two selects indexed by the for-generate genvar, in a continuous assignment
module top(output logic [3:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  for (genvar i = 0; i < 4; i++) begin : ga
    assign o[i] = z.g[i][1];
  end
endmodule
