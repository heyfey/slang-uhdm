// § bodyTdBoundSysCallClone303
package pk; parameter int N = 16; endpackage
module dut #(parameter int D = 4) (output logic o);
  typedef logic [$clog2(pk::N)-1:0] t_x [D];
  t_x a_x;
  t_x b_x;
  assign o = a_x[0][0] ^ b_x[1][0];
endmodule
