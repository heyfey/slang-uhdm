// § hpIdxCallNameSpan184: a call in a non-trailing index in a continuous assignment and a generate-scope process
module top #(parameter bit P = 1) (input logic clk);
  typedef struct packed { logic [3:0] v; } ps_t;
  typedef struct packed { ps_t [3:0] w; } pm_t;
  typedef struct packed { logic [3:0] f; } s_t;
  pm_t m;
  s_t s;
  int k;
  logic [3:0] r1;
  logic [15:0] arr;
  function automatic int g(int x); return x; endfunction
  logic [3:0] r2;
  assign r1 = m.w[g(1)].v;
  if (P) begin : gs
    always_ff @(posedge clk) r2 <= m.w[g(k)].v;
  end
endmodule
