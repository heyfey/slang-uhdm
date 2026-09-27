// § streamLvMemberPathRead184: a class method's streaming lvalue operand, two operands, a right-to-left stream with a slice size
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, x, z;
  class C;
    m_t q; int x;
    function void g(int j);
      {>>{q.w[j+1].v}} = x;
    endfunction
  endclass
  initial begin
    {>>{m.w[k].v, z}} = {x, x};
    {<<8{m.w[k+1].v}} = x;
  end
endmodule
