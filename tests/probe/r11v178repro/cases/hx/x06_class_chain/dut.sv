// § hierPathSelIdxAtPath178
class C;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  s_t arr[4];
  C o;
  function int f(int k);
    return this.m.w[k+1].v + o.arr[k-1].v + o.m.w[k*2].v;
  endfunction
endclass
module top; endmodule
