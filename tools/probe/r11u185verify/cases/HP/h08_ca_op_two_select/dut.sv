// § hierPathSelIdxAtPath178 § hierPathSelIdxCloneKeepsElem178v
module top(input logic [1:0] i, j, input logic [63:0] din, output logic [3:0] y1, y2, y3);
  typedef struct packed { logic [3:0] v; logic [3:0][3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  assign m = din;
  assign y1 = m.w[i].u[j] + 4'd1;
  assign y2 = m.w[i+1].u[j-1] ^ m.w[i].v;
  assign y3 = m.w[i].u[j+1];
endmodule
