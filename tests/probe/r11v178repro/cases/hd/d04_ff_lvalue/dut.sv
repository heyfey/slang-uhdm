// § hierPathSelIdxAtPath178
module top(input logic clk, input logic [1:0] k, input logic [3:0] d, output logic [31:0] q);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  always_ff @(posedge clk) begin
    m.w[k+1].v <= d;
    m.w[k].u <= m.w[k-1].v;
  end
  assign q = m;
endmodule
