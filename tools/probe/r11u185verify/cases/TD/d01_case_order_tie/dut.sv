// § tdEndMoveModuleOrder176
module dut import pa::*; (input logic [3:0] i, output logic o, p, q);
  s_t b;
  assign b = i;
  assign o = b.y;
  am u1(i, p);
  Zm u2(i, q);
endmodule
