package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
package q3;
  typedef logic [2:0] ut_e;
  typedef ut_e [1:0] row_t;
endpackage
module dut (input logic [5:0] i, output logic [5:0] o, output logic [5:0] p);
  q2::row_t a;
  q3::row_t b;
  assign a = i;
  assign b = ~i;
  assign o = a;
  assign p = b;
endmodule
