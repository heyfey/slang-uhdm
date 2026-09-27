// § trailIdxCallArgNamesByPath187 (inc/dec, nonblocking in a two-level generate)
module top #(parameter bit P = 1) (input logic clk, input int k);
  typedef struct { int q[4]; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  if (P) begin : ga
    if (P) begin : gb
      always_ff @(posedge clk) m.q[f(k)] <= 1;
      initial m.q[f(k)]++;
    end
  end
endmodule
