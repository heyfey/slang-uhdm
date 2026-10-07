// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// left side member multi-selects two generate levels down in an always_ff, and a generate continuous assignment
module top(input logic clk, input logic [1:0] k, input logic d, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  for (genvar i = 0; i < 2; i++) begin : ga
    for (genvar j = 0; j < 2; j++) begin : gb
      always_ff @(posedge clk) z.g[2*i+j][k[0]] <= d;
    end
  end
  assign o = z.b;
endmodule
