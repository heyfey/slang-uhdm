// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a foreach loop and a fork-join reading the path
module top(input logic [1:0] k, output logic [3:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  logic [3:0] tmp;
  assign z = '0;
  initial begin
    foreach (tmp[i]) tmp[i] = z.g[i][k[0]];
    fork
      o[0] = z.g[k][1];
      o[1] = z.g[k][0];
    join
  end
endmodule
