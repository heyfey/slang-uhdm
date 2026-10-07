// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a struct parameter member and a function call result as indices beside a plain one
module top(input logic [1:0] k, output logic o, output logic p);
  typedef struct packed { logic [1:0] x; logic [1:0] y; } c_t;
  localparam c_t CP = '{x: 2'd1, y: 2'd2};
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[CP.x][1];
  assign p = z.g[k][CP.y[0]];
endmodule
