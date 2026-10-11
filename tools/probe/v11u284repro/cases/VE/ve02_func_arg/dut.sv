// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (input logic [5:0] i, output logic [5:0] o);
  function automatic q2::row_t f(q2::row_t x); return x; endfunction
  assign o = f(i);
endmodule
