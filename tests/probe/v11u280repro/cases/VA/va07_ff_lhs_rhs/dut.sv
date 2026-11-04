// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a nonblocking left side and right side in an always_ff, both member multi-selects
module top(input logic clk, input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z, y;
  always_ff @(posedge clk) begin
    z.g[k][1] <= y.g[k][0];
    y.g[k][0] <= z.g[k][1];
  end
  assign o = z.b;
endmodule
