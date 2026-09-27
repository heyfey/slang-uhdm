// § genScopeTrailSelNameLate184: a generate block's function reading a trailing member select
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input int i, output logic y);
  s_t s;
  if (P) begin : gb
    function automatic logic rd(int k); return s.f[k]; endfunction
    always_comb y = rd(i);
  end
endmodule
