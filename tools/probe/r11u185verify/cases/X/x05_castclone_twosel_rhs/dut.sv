// § castRhsClonePerInst176 § hierPathSelIdxCloneKeepsElem178v § hierPathSelIdxAtPath178
module sub #(parameter int X = 1) (input logic [1:0] i, input logic [31:0] din, output logic [7:0] y1, y2, y3);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  assign m = din;
  assign y1 = 8'(m.w[i+1].v);
  assign y2 = 8'(m.w[i].u) + 8'(X);
  assign y3 = 8'(m.w[i^X].v + m.w[i].u);
endmodule
module top(input logic [1:0] i, input logic [31:0] din, output logic [7:0] a1, a2, a3, b1, b2, b3);
  sub u0(i, din, a1, a2, a3);
  sub #(.X(2)) u1(i, din, b1, b2, b3);
endmodule
