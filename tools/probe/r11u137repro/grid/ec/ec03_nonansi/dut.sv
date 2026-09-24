// § emptyNamedConnLowConnAtDecl137
module sub(a, b, c);
  input a;
  output b;
  output c;
  wire c;
  assign b = a; assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y), .c());
endmodule
