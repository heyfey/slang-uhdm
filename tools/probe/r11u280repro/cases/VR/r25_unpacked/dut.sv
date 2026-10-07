// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects on an unpacked member array
module top(input logic [1:0] k, output logic [7:0] o);
  typedef struct { logic [7:0] g [4][2]; logic b; } s_t;
  s_t z;
  always_comb begin
    z.b = 1'b0;
    for (int a = 0; a < 4; a++) for (int b = 0; b < 2; b++) z.g[a][b] = '0;
    o = z.g[k][1];
  end
endmodule
