// § tdEndMoveModuleOrder176
module dut import pa::*; (input logic [2:0] i, output logic o, p, q);
  s_t a [4];
  assign a[0] = i;
  assign o = a[0].y;
  mz u1(i, p);
  ma u2(i, q);
endmodule
