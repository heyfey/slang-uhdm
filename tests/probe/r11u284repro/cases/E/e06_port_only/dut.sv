// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (input q2::row_t i, output logic o);
  assign o = ^i;
endmodule
