// § hierPathSelIdxAtPath178
package pack;
typedef struct { int v; } s_t;
typedef struct { s_t w[4]; } m_t;
class c;
  m_t m, n;
  int arr[4];
  function int g(int x); return x; endfunction
  function int f(int k, bit b);
    int r;
    r = g(m.w[k].v);
    r += m.w[k].v + 1;
    r += b ? m.w[k].v : 0;
    r += arr[m.w[k].v];
    r += m.w[n.w[k].v].v;
    r += {m.w[k].v};
    return r;
  endfunction
endclass
endpackage
