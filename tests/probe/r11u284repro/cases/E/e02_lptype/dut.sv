// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut #(localparam type T = q2::row_t) (input logic [5:0] a, output logic [5:0] o);
  T x;
  assign x = a;
  assign o = x;
endmodule
