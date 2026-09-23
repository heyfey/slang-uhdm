package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; } s1_t;
  typedef struct packed { row_t [1:0] V; logic c; } s2_t;
  localparam s1_t P1 = '0;
  localparam s2_t P2 = '0;
endpackage
module dut (output logic [11:0] o, output logic [12:0] p);
  assign o = q2::P1;
  assign p = q2::P2;
endmodule
