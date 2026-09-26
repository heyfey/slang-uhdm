// § hierPathSelIdxCloneKeepsElem178v
module top(input logic [1:0] i, input logic [31:0] din, output logic [3:0] y, output logic [3:0] z, output int q);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  typedef struct { int v; } us_t;
  typedef struct { us_t w[4]; } um_t;
  m_t m;
  um_t um;
  int k;
  assign m = din;
  assign y = m.w[i].v;
  assign z = m.w[$clog2(k)].u;
  assign q = um.w[k].v + um.w[k+1].v;
endmodule
