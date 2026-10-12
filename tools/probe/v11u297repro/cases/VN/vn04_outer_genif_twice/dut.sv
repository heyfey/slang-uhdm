// § nestedDefPortsNeedShell297
module outer(input logic a, output logic y);
  module inner(input logic i, output logic o);
    assign o = i;
  endmodule
  inner u_in(.i(a), .o(y));
endmodule
module dut #(parameter bit S = 1) (input logic a, b, output logic y, z);
  if (S) begin : g
    outer u1(.a(a), .y(y));
  end
  outer u2(.a(b), .y(z));
endmodule
