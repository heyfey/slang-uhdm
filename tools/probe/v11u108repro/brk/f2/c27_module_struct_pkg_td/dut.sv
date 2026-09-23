package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (output logic [15:0] o);
  typedef struct packed { logic [3:0] pad; q2::row_t [0:1] U; } s_t;
  s_t v;
  assign v = '0;
  assign o = v;
endmodule
