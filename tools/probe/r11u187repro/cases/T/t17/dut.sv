// § trailIdxCallArgNamesByPath187 (control: calls as part-select bounds)
module top;
  typedef struct { logic [7:0] v; } m_t;
  m_t m;
  int k;
  logic [1:0] r;
  function automatic int f(int x); return x; endfunction
  initial begin
    r = m.v[f(k) +: 2];
    r = m.v[f(1):0];
  end
endmodule
