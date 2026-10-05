// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [2:0] k; } ix_t;
typedef struct packed { logic [15:0] d; } dat_t;
module top(input ix_t t, input dat_t s, output logic [1:0] y, output logic [1:0] y2);
  assign y = s.d[t.k +: 2];
  assign y2 = s.d[t.k + 3'd1 -: 2];
endmodule
