// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [1:0] k; } ix_t;
typedef struct { logic [7:0] v [4]; } arr_t;
module top(input ix_t t [2], input logic [7:0] d, output logic [7:0] y [2][2]);
  arr_t s;
  always_comb for (int i = 0; i < 4; i++) s.v[i] = d + i;
  for (genvar g1 = 0; g1 < 2; g1++) begin : G1
    for (genvar g2 = 0; g2 < 2; g2++) begin : G2
      assign y[g1][g2] = s.v[t[g1].k + g2];
    end
  end
endmodule
