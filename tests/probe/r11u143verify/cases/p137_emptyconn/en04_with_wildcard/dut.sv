// § emptyNamedConnLowConnAtDecl137
// case en04: an explicitly empty named connection next to a wildcard connection
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = ~a;
endmodule
module top(input logic a, output logic c);
  sub u(.*, .b());
endmodule
