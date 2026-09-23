package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t U; logic c; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [6:0] o);
  assign o = q2::P0;
endmodule
