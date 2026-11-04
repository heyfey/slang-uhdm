// § hierPathSelIdxAtPath178
module top;
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  int k;
  logic [15:0] x;
  initial begin
    {>>{m.w[k].v, m.w[k+1].u}} = 8'hA5;
    x = {<<4{m.w[k+2].v, m.w[k].u}};
  end
endmodule
