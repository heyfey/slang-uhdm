// § hierPathSelIdxCloneKeepsElem178v
module top(input logic [1:0] k, input logic [31:0] din, output logic [31:0] q);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  always_comb begin
    m = din;
    m.w[k+1].v |= 4'd1;
    m.w[k].v -= m.w[k+1].u;
    q = m;
  end
endmodule
