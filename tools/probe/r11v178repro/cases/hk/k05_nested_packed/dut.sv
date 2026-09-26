// § hierPathSelIdxCloneKeepsElem178v
module top(input logic [1:0] i, input logic [31:0] din, output logic [3:0] y);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  assign m = din;
  assign y = m.w[i+1].v ^ m.w[i^2'd1].u;
endmodule
