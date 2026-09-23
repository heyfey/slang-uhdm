package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [1:0][0:1] U; } s_t;
endpackage
module dut (input logic [27:0] a, output logic [27:0] o);
  q2::s_t v;
  assign v = a;
  assign o = v;
endmodule
