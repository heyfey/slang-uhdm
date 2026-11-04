// § emptyNamedConnLowConnAtDecl137
module sub(input logic a, d, output logic b, c);
  assign b = a ^ d; assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .d(), .b(y), .c());
endmodule
