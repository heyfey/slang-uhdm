// § bodyTdBoundSysCallClone303
module dut #(parameter int N = 8, parameter int D = 4) (output logic o);
  typedef logic [$clog2(N):0] t_x [D];
  t_x a_x;
  t_x b_x;
  assign o = a_x[0][0] ^ b_x[1][0];
endmodule
