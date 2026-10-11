// § pkgTdNamedDimsElemByChain284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module child #(parameter type T = logic [7:0]) (input T r, output logic o);
  assign o = ^r;
endmodule
module dut (input logic [5:0] r, output logic o);
  child #(.T(q2::row_t)) u (.r(r), .o(o));
endmodule
