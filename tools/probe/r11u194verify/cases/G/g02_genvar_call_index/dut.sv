// § genScopeTrailSelNameLate184 § hpIdxCallNameSpan184: trailing member selects in a generate loop indexed by the genvar and by a call, in always_comb and always_ff
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0] f; } s_t;
  function automatic logic [1:0] ix(input logic [1:0] x); return ~x; endfunction
  for (genvar gv = 0; gv < 2; gv++) begin : gl
    s_t t, u;
    always_comb t.f[gv] = u.f[ix(k)];
    always_ff @(posedge clk) u.f[ix(k)] <= t.f[gv + 1];
    assign o[gv*4 +: 4] = t.f;
  end
endmodule
