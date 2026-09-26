// § hierPathSelIdxAtPath178
module top(input logic [31:0] din, input logic [1:0] k, output logic [3:0] y [3]);
  typedef struct packed { logic [3:0] v; logic [3:0] u; } s_t;
  typedef struct packed { s_t [3:0] w; } m_t;
  m_t m;
  assign m = din;
  always_comb begin
    for (int j = 0; j < 3; j++) y[j] = m.w[j+1].v | m.w[k].u;
  end
endmodule
