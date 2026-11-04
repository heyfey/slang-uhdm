// § nestedDefPortsNeedShell297
module outer(input logic a, output logic y);
  module inner(input logic i, output logic o);
    assign o = i;
  endmodule
  inner u_in(.i(a), .o(y));
endmodule
module p1(input logic a, output logic y); outer u(.a(a), .y(y)); endmodule
module p2(input logic a, output logic y); outer u(.a(a), .y(y)); endmodule
module dut(input logic a, b, output logic y, z);
  p1 x1(.a(a), .y(y));
  p2 x2(.a(b), .y(z));
endmodule
