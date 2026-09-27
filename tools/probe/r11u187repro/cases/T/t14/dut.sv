// § trailIdxCallArgNamesByPath187 (streaming operands)
module top;
  typedef struct { logic [7:0] q; } m_t;
  m_t m;
  int k;
  logic [7:0] x;
  function automatic int f(int y); return y; endfunction
  initial begin
    x = {>>{m.q[f(k)]}};
    {>>{m.q[f(k)]}} = x[0];
  end
endmodule
