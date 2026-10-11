// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut(output logic [1:0] o);
  localparam q2::row_t UT = 6'h24;
  assign o = UT[1];
endmodule
