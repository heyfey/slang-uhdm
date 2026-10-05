// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [1:0] k; logic [1:0] j; } ix_t;
typedef struct packed { logic [7:0] w; logic [7:0] z; } el_t;
module top(input ix_t t, input el_t d, output logic [7:0] y);
  el_t s [4];
  always_comb begin
    for (int i = 0; i < 4; i++) s[i] = d;
  end
  assign y = s[t.k].w;
endmodule
