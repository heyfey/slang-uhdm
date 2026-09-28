// § pkgTopWidePatReplTsName210 — vw04 (v11u210 break probe): the replication of a NONZERO value and a replication count written as a parenthesized product, the pattern read by a qualified member select in a module
package vp;
  localparam int N = 2;
  typedef struct packed { logic [3:0][63:0] A; bit E; } s_t;
  localparam s_t S = '{ A: {(N*2){64'h5A}}, E: 1'b0 };
endpackage
module dut(output logic [63:0] o);
  assign o = vp::S.A[1];
endmodule
