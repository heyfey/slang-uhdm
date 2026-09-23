package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (input logic [5:0] i, output logic [5:0] o, output logic [3:0] p);
  import q2::*;
  typedef logic [3:0] ut_e;
  row_t r;
  ut_e u;
  assign r = i;
  assign u = i[3:0];
  assign o = r;
  assign p = u;
endmodule
