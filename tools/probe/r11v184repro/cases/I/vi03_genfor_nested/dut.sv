// § incDecMemberSelIsLvalue184: inc/dec member selects indexed by a genvar in a generate-for body, and through a nested member, pre and post
typedef struct packed { logic [3:0] g; } in_t;
typedef struct packed { in_t a; logic [7:0] f; } s_t;
module top (input logic clk);
  s_t s;
  int i;
  for (genvar gi = 0; gi < 2; gi++) begin : gf
    always_ff @(posedge clk) begin
      s.f[gi]++;
      ++s.a.g[gi];
    end
  end
  always_ff @(posedge clk) begin
    s.a.g[i]--;
    --s.a.g[i + 1];
  end
endmodule
