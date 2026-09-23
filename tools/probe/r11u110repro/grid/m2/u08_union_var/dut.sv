package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef union packed { row_t [0:1] U; logic [11:0] w; } u_t;
endpackage
module dut (input logic [11:0] a, output logic [11:0] o);
  q2::u_t v;
  assign v = a;
  assign o = v;
endmodule
