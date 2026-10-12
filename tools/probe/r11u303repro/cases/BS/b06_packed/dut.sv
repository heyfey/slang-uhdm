// § bodyTdBoundSysCallClone303
module dut #(parameter int N = 8) (output logic o);
  typedef logic [$clog2(N)-1:0] t_x;
  t_x a_x;
  t_x b_x;
  assign o = a_x[0] ^ b_x[0];
endmodule
