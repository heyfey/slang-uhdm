// § tdEndMoveModuleOrder176
module dut (input logic [2:0] i, output logic p, q);
  zi u1(i, p);
  ma u2(i, q);
endmodule
