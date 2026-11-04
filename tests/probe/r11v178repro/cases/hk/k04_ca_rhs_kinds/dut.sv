// § hierPathSelIdxCloneKeepsElem178v
module top(input logic [1:0] i, input logic c, input logic [31:0] din,
           output logic [3:0] y1, y2, y3, y4, output logic [7:0] y5, output logic [3:0] y6);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  function automatic logic [3:0] f(logic [3:0] x); return x; endfunction
  assign m = din;
  assign y1 = m.w[i+1].v;
  assign y2 = f(m.w[i+1].u);
  assign y3 = c ? m.w[i-1].v : m.w[i].u;
  assign y4 = ~m.w[i^1].v;
  assign y5 = {m.w[i+2].v, m.w[i].u};
  wire [3:0] nd = m.w[i+3].v & m.w[i].v;
  assign y6 = nd;
endmodule
