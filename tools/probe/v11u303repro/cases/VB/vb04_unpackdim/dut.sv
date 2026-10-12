// § bodyTdBoundSysCallClone303
module dut #(parameter int N = 8) (output logic o);
  typedef logic [3:0] t_x [$clog2(N)];
  t_x a_x;
  t_x b_x;
  assign o = a_x[0][0] ^ b_x[1][0];
endmodule
