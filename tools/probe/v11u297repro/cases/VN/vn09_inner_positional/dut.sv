// § nestedDefPortsNeedShell297
module outer(input logic a, output logic y);
  module inner(input logic i, output logic o);
    assign o = !i;
  endmodule
  inner u_in(a, y);
endmodule
module dut(input logic a, b, output logic y, z);
  outer u1(a, y);
  outer u2(b, z);
endmodule
