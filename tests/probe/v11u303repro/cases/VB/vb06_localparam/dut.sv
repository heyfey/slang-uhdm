// § bodyTdBoundSysCallClone303
module dut #(parameter int D = 4) (output logic o);
  localparam int N = 33;
  typedef logic [$clog2(N)-1:0] t_x [D];
  t_x a_x;
  t_x b_x;
  assign o = a_x[0][0] ^ b_x[1][0];
endmodule
