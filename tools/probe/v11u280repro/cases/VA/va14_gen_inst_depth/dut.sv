// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a for-generate instance array of a child reading the path two levels down
module kid(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  for (genvar i = 0; i < 2; i++) begin : g1
    if (i == 0) begin : g2
      always_comb o = z.g[k][i];
    end
  end
endmodule
module top(input logic [1:0] k, output logic [1:0] o);
  for (genvar j = 0; j < 2; j++) begin : gt
    kid u (.k(k), .o(o[j]));
  end
endmodule
