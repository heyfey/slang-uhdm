// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (output logic [5:0] o);
  localparam q2::row_t L = 6'h11;
  assign o = L;
endmodule
