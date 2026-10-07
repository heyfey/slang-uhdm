// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// an unpacked struct with packed 2-D member read in an always_comb, and three selects
module top(input logic [1:0] k, output logic o, output logic p);
  typedef struct { logic [3:0][1:0] g; logic [1:0][3:0][1:0] h; } s_t;
  s_t z;
  always_comb begin
    z.g = '0; z.h = '0;
    o = z.g[k][1];
    p = z.h[1][k][0];
  end
endmodule
