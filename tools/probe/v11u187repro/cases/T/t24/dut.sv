// § trailIdxCallArgNamesByPath187 (array-element base, port connection)
module sub(input logic a);
endmodule
module top(input int k);
  typedef struct packed { logic [7:0] q; } m_t;
  m_t arr [2];
  int r;
  function automatic int f(int x); return x; endfunction
  initial r = arr[1].q[f(k)];
  sub u(.a(arr[0].q[f(k)]));
endmodule
