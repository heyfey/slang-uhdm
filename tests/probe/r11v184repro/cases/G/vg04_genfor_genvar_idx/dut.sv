// § genScopeTrailSelNameLate184: a generate-for body's process reading and writing trailing member selects indexed by the genvar
typedef struct packed { logic [7:0] f; } s_t;
module top (input logic clk);
  s_t s, t;
  for (genvar gi = 0; gi < 2; gi++) begin : gf
    always_ff @(posedge clk) t.f[gi + 4] <= s.f[gi];
  end
endmodule
