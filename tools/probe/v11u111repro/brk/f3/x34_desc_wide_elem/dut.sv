package q2;
  typedef logic [3:0] ut_e;
  typedef ut_e [2:0] row_t;
  localparam row_t R0 = 12'habc;
endpackage
module dut (output logic [11:0] o);
  import q2::*;
  row_t v;
  assign v = R0;
  assign o = v;
endmodule
