// § bodyTdBoundSysCallClone303
interface ifc #(parameter int N = 8);
  typedef logic [$clog2(N)-1:0] t_x [2];
  t_x a_x;
endinterface
module dut (output logic o);
  ifc u ();
  assign o = u.a_x[0][0];
endmodule
