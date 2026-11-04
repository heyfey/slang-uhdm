// § emptyNamedConnLowConnAtDecl137
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y), .c());
endmodule
