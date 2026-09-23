package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:1] row_t;
  typedef struct packed { logic pad; row_t [1:0][1:0][1:0] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [32:0] o);
  assign o = q2::P0;
endmodule
