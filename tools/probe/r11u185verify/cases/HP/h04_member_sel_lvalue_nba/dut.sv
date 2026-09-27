// § hierPathSelIdxAtPath178
module top(input logic clk);
  typedef struct { int v; logic [7:0] u[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, j;
  always_ff @(posedge clk) begin
    m.w[k+1].v <= 3;
    m.w[k].u[j+1] <= m.w[k-1].v;
  end
endmodule
