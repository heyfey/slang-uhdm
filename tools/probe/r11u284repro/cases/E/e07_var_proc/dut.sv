// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (input logic [5:0] i, output logic [5:0] o);
  q2::row_t a;
  always_comb a = i;
  assign o = a;
endmodule
