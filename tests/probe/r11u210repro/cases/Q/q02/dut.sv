// § pkgTopWidePatReplTsName210 — q02: decode-only (stage 1 on both binaries), a whole package parameter initialized by a qualified enum constant, and an unqualified member after an import
package ep;
  typedef enum logic [1:0] { NA, NB, NC } k_e;
  typedef struct packed { k_e K; logic [3:0] N; } s_t;
endpackage
package vp;
  import ep::*;
  localparam ep::k_e X = ep::NC;
  localparam s_t S = '{ K: NB, N: 4'd1 };
endpackage
module dut(output logic [1:0] o, output logic [1:0] p);
  assign o = vp::X;
  assign p = vp::S.K;
endmodule
