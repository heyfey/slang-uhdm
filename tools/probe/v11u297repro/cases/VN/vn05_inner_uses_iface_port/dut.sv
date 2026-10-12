// § nestedDefPortsNeedShell297
interface bus; logic d; endinterface
module outer(input logic a, output logic y);
  bus b();
  module inner(bus p, input logic i, output logic o);
    assign p.d = i;
    assign o = p.d;
  endmodule
  inner u_in(.p(b), .i(a), .o(y));
endmodule
module dut(input logic a, b, output logic y, z);
  outer u1(.a(a), .y(y));
  outer u2(.a(b), .y(z));
endmodule
