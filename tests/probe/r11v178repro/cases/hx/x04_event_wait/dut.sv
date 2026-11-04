// § hierPathSelIdxAtPath178
module top;
  typedef struct { logic v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, r;
  initial begin
    @(m.w[k+1].v) r = 1;
    wait (m.w[k*2].v) r = 2;
    if (m.w[k-1].v) r = 3;
    case (m.w[k^1].v) 1'b1: r = 4; default: r = 5; endcase
  end
endmodule
