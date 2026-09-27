// § lvIdxReadCallNameSpan181v § lvIdxMixedPathIsRead181 (v11u181 break, fixed: a call, a plain member read, a select and an operation in the index of a path nested in an lvalue index)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m, n;
  s_t s;
  int k;
  int arr[8];
  function automatic int f(int a); return a; endfunction
  initial begin
    m.w[n.w[s.v].v].v = 2;
    m.w[n.w[arr[k]].v].v = 3;
    m.w[n.w[f(k)].v].v = 4;
    arr[n.w[k+1].v] = 5;
  end
endmodule
