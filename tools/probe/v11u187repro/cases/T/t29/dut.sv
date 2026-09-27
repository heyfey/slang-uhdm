// § trailIdxCallArgNamesByPath187 (a genvar argument and a parameter argument)
module top #(parameter int P = 2) (output logic [3:0] y);
  typedef struct packed { logic [7:0] q; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  for (genvar gi = 0; gi < 4; gi++) begin : g
    assign y[gi] = m.q[f(gi) + f(P)];
  end
endmodule
