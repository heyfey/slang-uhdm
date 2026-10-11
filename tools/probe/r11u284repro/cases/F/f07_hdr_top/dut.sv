// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut #(parameter q2::row_t P = 6'h11) (output logic [5:0] o);
  assign o = P;
endmodule
