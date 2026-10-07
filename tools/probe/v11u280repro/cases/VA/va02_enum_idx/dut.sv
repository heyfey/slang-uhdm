// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// an enum constant and a localparam as the indices
module top(output logic o, output logic p);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  localparam int LP = 2;
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[C][1];
  assign p = z.g[LP][B];
endmodule
