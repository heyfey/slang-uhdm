// § hierPathSelIdxAtPath178
module top(input logic clk);
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, r;
  always_ff @(posedge clk) begin
    m.w[k+1].v <= 1;
    r <= m.w[k+1].v;
  end
endmodule
