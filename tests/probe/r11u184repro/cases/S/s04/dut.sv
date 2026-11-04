// § streamLvMemberPathRead184 (controls): a member path without a select, a plain element select, and a streaming rvalue
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  s_t s;
  int arr [4];
  int k, x, y;
  initial begin
    {>>{s.v}} = x;
    {<<{arr[k]}} = x;
    y = {>>{m.w[k].v}};
  end
endmodule
