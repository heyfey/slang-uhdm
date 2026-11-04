// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int arr[4];
  int k, r1, r2, r3, r4, r5, r6;
  function automatic int f(int x); return x; endfunction
  function automatic int g(); return 1; endfunction
  initial begin
    r1 = m.w[f(k)].v;
    r2 = arr[f(k)];
    r3 = m.w[g()].v;
    r4 = arr[f(k) + 1];
    r5 = m.w[k].v + f(k);
    r6 = arr[$clog2(k)];
    arr[f(k)] = 1;
  end
endmodule
