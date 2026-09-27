// § genScopeTrailSelNameLate184: trailing member selects in generate-scope processes (reads, writes, nested blocks, a generate-for)
typedef struct packed { logic [7:0] f; logic [3:0][1:0] g; } s_t;
module top #(parameter bit P = 1, parameter bit Q = 1) (input logic clk, input s_t s, input logic [2:0] i, output logic [7:0] y);
  s_t t;
  if (P) begin : ga
    logic z;
    always_ff @(posedge clk) begin
      z <= s.f[i];
      t.f[i] <= z;
    end
    if (Q) begin : gb
      logic [1:0] w;
      always_comb w = s.g[i[1:0]];
    end
  end
  for (genvar k = 0; k < 2; k++) begin : gf
    logic v;
    always_comb v = s.f[k + i];
  end
  assign y = t.f;
endmodule
