// § nestedDefPortsNeedShell297
module leaf(input logic i, output logic o); assign o = i; endmodule
module outer(input logic a, output logic y);
  module inner(input logic i, output logic o);
    leaf l(.i(i), .o(o));
  endmodule
  inner u_in(.i(a), .o(y));
endmodule
module dut(input logic a, b, output logic y, z);
  outer u1(.a(a), .y(y));
  outer u2(.a(b), .y(z));
endmodule
