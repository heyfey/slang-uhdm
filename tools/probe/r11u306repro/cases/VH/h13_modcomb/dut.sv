// § varSelIdxHpLeafByPath306
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [15:0][7:0] f; } s_t;
module top(input logic [3:0] n, output logic [7:0] r);
  s_t s; t_t t; logic [3:0] m2 [4][4];
  always_comb r = s.f[n + m2[1][t.k]];
endmodule
