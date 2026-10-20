// § hierSelParenBoundPretty417
module top #(parameter int N = 4) (output logic [3:0] o [N]);
  typedef struct packed { logic [63:0] d; } s_t;
  s_t s;
  for (genvar g = 0; g < N; g++) begin : gl
    assign o[g] = s.d[(g*4)+:4];
  end
endmodule
