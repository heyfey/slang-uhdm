// § hierPathSelIdxCloneKeepsElem178v
package p;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  function automatic void pf(ref m_t m, input int k); m.w[k+1].v++; m.w[k].v--; endfunction
endpackage
class C;
  p::m_t m;
  function void f(int k); m.w[k+1].v++; --m.w[k*2].v; m.w[k].v++; endfunction
endclass
module top;
  p::m_t m;
  int k;
  function automatic void mf(int j); m.w[j+1].v++; m.w[j].v++; endfunction
  always_comb m.w[k-1].v++;
  initial begin
    for (int i = 0; i < 2; m.w[i+1].v++) i++;
    m.w[k].v++;
  end
endmodule
