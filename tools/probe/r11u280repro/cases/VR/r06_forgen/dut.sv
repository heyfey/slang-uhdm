// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects in a for-generate continuous assignment, genvar index
module top(input logic [1:0] k, output logic [1:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  for (genvar i = 0; i < 2; i++) begin : gl
    assign o[i] = z.g[k][i];
  end
endmodule
