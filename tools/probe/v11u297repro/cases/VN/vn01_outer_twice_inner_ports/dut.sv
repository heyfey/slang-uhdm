// § nestedDefPortsNeedShell297
module outer(input logic a, output logic y);
  module inner(input logic i, output logic o);
    assign o = ~i;
  endmodule
  inner u_in(.i(a), .o(y));
endmodule
module dut(input logic a, b, output logic y, z);
  outer u1(.a(a), .y(y));
  outer u2(.a(b), .y(z));
endmodule
