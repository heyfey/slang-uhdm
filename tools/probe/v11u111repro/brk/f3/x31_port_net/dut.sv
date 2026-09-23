package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub (input q2::row_t a, output q2::row_t b);
  wire q2::row_t w = a;
  assign b = w;
endmodule
module dut (input logic [5:0] i, output logic [5:0] o);
  sub u (.a(i), .b(o));
endmodule
