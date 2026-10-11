// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut import q2::*; (input logic [5:0] i, output logic [5:0] o);
  row_t a;
  assign a = i;
  assign o = a;
endmodule
