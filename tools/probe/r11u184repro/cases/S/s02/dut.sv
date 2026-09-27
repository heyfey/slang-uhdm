// § streamLvMemberPathRead184 (control): the same member path as a plain read
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, x;
  initial begin
    x = m.w[k+2].v;
  end
endmodule
