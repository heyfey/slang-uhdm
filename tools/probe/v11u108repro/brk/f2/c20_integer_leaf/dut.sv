package q2;
  typedef integer ut_e;
  typedef ut_e [1:0] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [131:0] o);
  assign o = q2::P0;
endmodule
