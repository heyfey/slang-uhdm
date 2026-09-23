package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (output logic [5:0] o);
  q2::row_t r;
  assign r = '0;
  assign o = r;
endmodule
