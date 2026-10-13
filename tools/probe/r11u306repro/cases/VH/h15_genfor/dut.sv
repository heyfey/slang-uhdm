// § varSelIdxHpLeafByPath306
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [15:0][7:0] f; } s_t;
module top(input logic [3:0] n, output logic [7:0] r [2]);
  s_t s; t_t t; logic [3:0] m2 [4][4];
  for (genvar g = 0; g < 2; g++) begin : gb
    assign r[g] = s.f[n + m2[g][t.k]];
  end
endmodule
