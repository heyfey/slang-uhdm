// § pkgTopWidePatReplTsName210 — q04: a WIDE (> 64 bits) package struct pattern with a replication member and a qualified enum member (FuncStructVal cva6_cfg shape)
package ep;
  typedef enum logic [1:0] { NA, NB, NC } k_e;
  typedef struct packed { k_e K; logic [7:0][63:0] W; logic [3:0] N; } s_t;
endpackage
package vp;
  localparam ep::s_t S = '{
      K: ep::NC,
      W: {8{64'h0}},
      N: 4'd3
  };
endpackage
module dut(output logic [1:0] o);
  assign o = vp::S.K;
endmodule
