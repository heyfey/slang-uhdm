package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef union packed { row_t [1:0][0:1] U; logic [23:0] w; } u_t;
  localparam u_t P0 = '0;
endpackage
module dut (output logic [23:0] o);
  assign o = q2::P0;
endmodule
