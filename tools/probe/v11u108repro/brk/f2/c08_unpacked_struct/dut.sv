package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct { logic [3:0] pad; row_t [0:1] U; } s_t;
endpackage
module dut (output logic [5:0] o);
  q2::s_t v;
  assign v.U[0] = 6'h5;
  assign o = v.U[0];
endmodule
