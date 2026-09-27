// § hierPathSelIdxCloneKeepsElem178v § castRhsClonePerInst176
module top(input logic [1:0] i, input logic [31:0] din, output logic [3:0] y1, output logic [4:0] y2,
           output logic [3:0] y3, output logic [7:0] y4);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  function automatic logic [3:0] f(logic [3:0] x); return ~x; endfunction
  assign m = din;
  assign y1 = 4'(m.w[i+1].v);
  assign y2 = {m.w[i^1].v, 1'b0};
  assign y3 = f(m.w[i-1].u);
  assign y4 = 8'(m.w[i].u + m.w[i+2].v);
endmodule
