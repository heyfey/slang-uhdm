// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef ut_e [1:0] pair_t;
endpackage
module dut (input logic [5:0] i, output logic [5:0] o, output logic [3:0] p);
  q2::row_t a;
  q2::pair_t b;
  always_comb a = i;
  assign b = i[3:0];
  assign o = a;
  assign p = b;
endmodule
