// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
package q3;
  typedef struct packed { q2::row_t m; logic v; } s_t;
endpackage
module dut (input q3::s_t s, output logic o);
  assign o = ^s;
endmodule
