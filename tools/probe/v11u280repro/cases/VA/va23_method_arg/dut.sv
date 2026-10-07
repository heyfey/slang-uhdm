// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the path as a queue method argument and an inside-set member
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  logic q [$];
  assign z = '0;
  initial begin
    q.push_back(z.g[k][1]);
    o = z.g[k][0] inside {1'b1, z.g[k][1]};
  end
endmodule
