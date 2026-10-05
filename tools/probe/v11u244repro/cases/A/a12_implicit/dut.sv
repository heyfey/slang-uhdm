// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [1:0] k; } ix_t;
typedef struct packed { logic [3:0] v; } dat_t;
module sub(input logic [1:0] a, output logic [1:0] b); assign b = a; endmodule
module top(input dat_t s, input logic [1:0] x, output logic y);
  ix_t t;
  sub u(.a(x), .b(nn));
  assign t.k = nn;
  assign y = s.v[t.k];
endmodule
