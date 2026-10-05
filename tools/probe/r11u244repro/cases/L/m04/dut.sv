// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [3:0] k; logic [3:0] j; } ix_t;
typedef struct { logic [7:0] v [16]; logic [7:0] w; } arr_t;
module top(input ix_t t, output logic [7:0] y, output logic [7:0] y2);
  arr_t s;
  ix_t u;
  genvar g;
  for (g = 0; g < 2; g++) begin : gb
    assign y2 = s.v[t.k];
  end
  assign y = s.w;
endmodule
