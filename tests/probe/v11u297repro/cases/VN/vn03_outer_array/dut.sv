// § nestedDefPortsNeedShell297
module outer(input logic a, output logic y);
  module inner(input logic i, output logic o);
    assign o = i;
  endmodule
  inner u_in(.i(a), .o(y));
endmodule
module dut(input logic [2:0] a, output logic [2:0] y);
  outer u[2:0](.a(a), .y(y));
endmodule
