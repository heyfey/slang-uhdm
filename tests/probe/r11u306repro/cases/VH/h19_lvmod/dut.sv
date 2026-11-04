// § varSelIdxHpLeafByPath306
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [15:0][7:0] f; } s_t;
module top(input logic [3:0] n, output s_t so);
  t_t t; logic [3:0] m2 [4][4];
  always_comb begin so = '{default:0}; so.f[n + m2[1][t.k]] = 8'h5; end
endmodule
