// § trailIdxCallArgNamesByPath187
module top(input logic clk, input int k);
  typedef struct packed { logic [3:0] q; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  always_ff @(posedge clk) m.q[f(k)] <= 1'b1;
endmodule
