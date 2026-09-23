package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  localparam row_t R0 = '{default: 2'b01};
endpackage
module dut (output logic [5:0] o);
  import q2::*;
  localparam row_t R1 = R0;
  assign o = R1;
endmodule
