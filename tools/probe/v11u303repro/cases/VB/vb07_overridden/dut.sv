// § bodyTdBoundSysCallClone303
module sub #(parameter int N = 8, parameter int D = 4) (output logic o);
  typedef logic [$clog2(N)-1:0] t_x [D];
  t_x a_x;
  t_x b_x;
  assign o = a_x[0][0] ^ b_x[1][0];
endmodule
module dut (output logic o1, o2);
  sub #(.N(64)) u1 (.o(o1));
  sub u2 (.o(o2));
endmodule
