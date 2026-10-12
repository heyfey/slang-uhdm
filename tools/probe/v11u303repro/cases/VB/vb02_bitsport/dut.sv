// § bodyTdBoundSysCallClone303
module dut #(parameter int D = 4) (input logic [5:0] p, output logic o);
  typedef logic [$bits(p)-1:0] t_x [D];
  t_x a_x;
  t_x b_x;
  assign o = a_x[0][0] ^ b_x[1][0] ^ p[0];
endmodule
