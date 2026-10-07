// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a for-generate continuous assignment left side indexed by the genvar and a right side indexed by a generate localparam
module top(input logic [1:0] k, output logic [8:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z, y;
  assign y = '0;
  for (genvar i = 0; i < 4; i++) begin : ga
    localparam int L = i % 2;
    assign z.g[i][L] = y.g[i][L];
    assign z.g[i][1-L] = y.g[k][L];
  end
  assign z.b = 1'b0;
  assign o = z;
endmodule
