// § hierPathSelIdxAtPath178
module top;
  typedef struct { logic [7:0] v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k;
  logic [15:0] r;
  initial begin
    r = {m.w[k+1].v, 8'h0};
    $display("%0d", m.w[k-1].v);
    r = {>>{m.w[k^1].v}};
  end
endmodule
