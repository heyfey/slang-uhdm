// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [1:0] k; } ix_t;
typedef struct { logic [1:0] w [4]; } mid_t;
typedef struct { logic [7:0] v [4]; } arr_t;
module top(input ix_t t, input logic [7:0] d, output logic [7:0] y);
  arr_t s; mid_t u;
  always_comb begin
    for (int i = 0; i < 4; i++) begin s.v[i] = d + i; u.w[i] = i[1:0]; end
    y = s.v[u.w[t.k]];
  end
endmodule
