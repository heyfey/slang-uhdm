package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef row_t [1:0] mat_t;
  typedef row_t row2_t;
endpackage
module dut (input logic [11:0] i, output logic [11:0] o, output logic [5:0] p);
  q2::mat_t m;
  q2::row2_t r2;
  assign m = i;
  assign r2 = i[5:0];
  assign o = m;
  assign p = r2;
endmodule
