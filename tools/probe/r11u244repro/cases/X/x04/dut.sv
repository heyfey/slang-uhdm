// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [3:0] k; logic [1:0] j; } ix_t;
typedef struct packed { logic [15:0] d; } st_t;
module top(input ix_t t, input st_t s, output logic [1:0] y, output logic [3:0] y2, output logic y3);
  assign y = s.d[t.k +: 2];
  assign y2 = s.d[t.j +: 4];
  assign y3 = s.d[t.k];
  assign imp = s.d[t.k];
  genvar g;
  for (g = 0; g < 2; g++) begin : gb
    for (genvar h = 0; h < 2; h++) begin : hb
      wire w = s.d[t.k + g + h];
    end
  end
endmodule
