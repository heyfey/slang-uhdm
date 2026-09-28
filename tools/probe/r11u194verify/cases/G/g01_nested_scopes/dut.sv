// § genScopeTrailSelNameLate184: trailing member selects read and written in processes of NESTED generate scopes (if inside for inside a named block)
module top (input logic clk, input logic [1:0] k, output logic [3:0] o);
  typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t;
  if (1) begin : ga
    s_t r;
    for (genvar i = 0; i < 2; i++) begin : gb
      if (i == 1) begin : gc
        s_t t;
        always @(posedge clk) begin
          t.f[k] <= r.g[k];
          r.f[k] <= t.g[i];
        end
        assign o = t.f;
      end
    end
  end
endmodule
