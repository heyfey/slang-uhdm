// § emptyNamedConnLowConnAtDecl137
module sub(input logic a, output logic b, c, d);
  assign b = a; assign c = a; assign d = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y), .c(), .d());
endmodule
