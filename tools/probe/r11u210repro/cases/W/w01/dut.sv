// § pkgTopWidePatReplTsName210 — w01: a wide package struct pattern with two replication members and a sized literal, read through a wildcard import in a module
package vp;
  typedef struct packed { logic [3:0][63:0] A; logic [1:0][63:0] B; logic [7:0] N; } s_t;
  localparam s_t S = '{
      A: {4{64'h1}},
      B: {2{64'hffff}},
      N: 8'd7
  };
endpackage
module dut(output logic [7:0] o);
  import vp::*;
  assign o = S.N;
endmodule
