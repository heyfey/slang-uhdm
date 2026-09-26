// § hierPathSelIdxAtPath178
package p;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  function automatic int f(m_t m, int k);
    return m.w[k+1].v + m.w[k].v;
  endfunction
endpackage
module top; import p::*; m_t mm; int r; initial r = f(mm, 1); endmodule
