// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [1:0] k; } ix_t;
typedef struct { logic [7:0] v [4]; } arr_t;
module sub(input logic [7:0] x, output logic [7:0] o); assign o = ~x; endmodule
module top(input ix_t t, input logic [7:0] d, output logic [7:0] y);
  arr_t s;
  always_comb for (int i = 0; i < 4; i++) s.v[i] = d + i;
  sub u(.x(s.v[t.k]), .o(y));
endmodule
