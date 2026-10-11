// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
package p3;
  typedef struct packed { q2::row_t r; logic x; } s_t;
endpackage
module dut (input logic [6:0] i, output logic [6:0] o);
  p3::s_t a;
  assign a = i;
  assign o = a;
endmodule
