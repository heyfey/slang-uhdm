// § nestedDefPortsNeedShell297
module outer(input logic a, output logic y, z);
  module inner(input logic i, output logic o);
    assign o = i;
  endmodule
  inner u_a(.i(a), .o(y));
  inner u_b(.i(!a), .o(z));
endmodule
module dut(input logic a, b, output logic y, z, w, v);
  outer u1(.a(a), .y(y), .z(z));
  outer u2(.a(b), .y(w), .z(v));
endmodule
