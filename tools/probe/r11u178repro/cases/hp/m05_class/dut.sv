// § hierPathSelIdxAtPath178
package p;
  typedef struct { int v; int x[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  class c;
    m_t m; s_t a[4];
    function int f(int k, int j);
      int r;
      r = a[k].v;
      r += m.w[k].v;
      r += m.w[k].x[j];
      return r;
    endfunction
  endclass
endpackage
