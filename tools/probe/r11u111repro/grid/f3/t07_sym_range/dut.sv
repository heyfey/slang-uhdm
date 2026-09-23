package q2;
  localparam int N = 3;
  typedef logic [1:0] ut_e;
  typedef ut_e [N-1:0] row_t;
  typedef struct packed { row_t [0:1] U; logic c; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [12:0] o);
  assign o = q2::P0;
endmodule
