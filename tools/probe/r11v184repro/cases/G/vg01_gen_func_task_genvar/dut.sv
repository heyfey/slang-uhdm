// § genScopeTrailSelNameLate184: trailing member selects in a generate block's function and task, a generate-for genvar index, a named begin, reads and writes
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input logic clk, input int i, output logic y);
  s_t s, t;
  if (P) begin : gb
    function automatic logic rd(int k); return s.f[k]; endfunction
    task automatic wr(int k); t.f[k] = 1'b1; endtask
    always_ff @(posedge clk) begin : nb
      t.f[i] <= s.f[i];
      y <= rd(i);
    end
  end
  for (genvar gi = 0; gi < 2; gi++) begin : gf
    always_comb t.f[gi + 4] = s.f[gi];
  end
endmodule
