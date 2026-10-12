// § bodyTdBoundSysCallClone303
module sub #(parameter int N = 8) (output logic o);
  typedef logic [$clog2(N)-1:0] t_x [2];
  t_x a_x;
  assign o = a_x[0][0];
endmodule
module dut (output logic o, p);
  sub #(.N(16)) u (.o(o));
  sub #(.N(4)) v (.o(p));
endmodule
