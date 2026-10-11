// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
interface ifc;
  q2::row_t r;
endinterface
module dut (input logic [5:0] i, output logic [5:0] o);
  ifc u();
  assign u.r = i;
  assign o = u.r;
endmodule
