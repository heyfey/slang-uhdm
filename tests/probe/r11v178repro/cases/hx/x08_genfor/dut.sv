// § hierPathSelIdxAtPath178
module top;
  typedef struct packed { logic [3:0] v; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  logic [3:0] r [3];
  logic [1:0] k;
  for (genvar g = 0; g < 3; g++) begin : G
    assign r[g] = m.w[g+1].v ^ m.w[k+g].v;
  end
endmodule
