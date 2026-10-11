// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
package q3;
  localparam q2::row_t PP = 6'h5;
endpackage
module dut (output logic [5:0] o);
  assign o = q3::PP;
endmodule
