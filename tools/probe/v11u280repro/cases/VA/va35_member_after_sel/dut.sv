// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// an element select then a member then two selects, and an element-select-only member path beside
module top(input logic [1:0] k, output logic o, output logic p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  typedef struct packed { s_t [1:0] h; } t_t;
  t_t w;
  assign w = '0;
  assign o = w.h[1].g[k][1];
  assign p = w.h[k].b;
endmodule
