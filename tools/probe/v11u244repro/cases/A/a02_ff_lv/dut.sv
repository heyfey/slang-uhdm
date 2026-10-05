// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [3:0] k; logic [3:0] j; } ix_t;
typedef struct { logic [7:0] v [16]; logic [7:0] w; } arr_t;
module top(input logic clk, input ix_t t, input logic [7:0] d, output logic [7:0] y);
  arr_t s;
  always_ff @(posedge clk) s.v[t.k] <= d;
  assign y = s.v[t.j];
endmodule
