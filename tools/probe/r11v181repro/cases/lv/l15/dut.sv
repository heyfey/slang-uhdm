// § classMethodLvIsProcess181 § lvIdxMixedPathIsRead181 (v11u181 break: a class method: a path nested in an lvalue index, a streaming lvalue, a plain array lvalue indexed by a path)
typedef struct { int v; } s_t;
typedef struct { s_t w[4]; } m_t;
class C;
  m_t m, n;
  int arr[8];
  int x;
  function void f(int k);
    m.w[n.w[k].v].v = 1;
    arr[n.w[k].v] = 2;
    {>>{m.w[k].v}} = x;
  endfunction
endclass
module top; initial begin C c = new; c.f(0); end endmodule
