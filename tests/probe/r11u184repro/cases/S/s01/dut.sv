// § streamLvMemberPathRead184: member paths through selects as streaming-concatenation lvalue operands
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, x;
  initial begin
    {>>{m.w[k+2].v}} = x;
  end
endmodule
