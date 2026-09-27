// § incDecMixedPathIsLvalue181 (v11u181 break: inc/dec through a class handle's array member and two member levels after a select)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t s; } e_t;
  typedef struct { e_t w[4]; } m_t;
  class H; s_t arr[4]; endclass
  H h;
  m_t m;
  int i;
  initial begin
    h = new;
    h.arr[i].v++;
    m.w[i].s.v++;
  end
endmodule
