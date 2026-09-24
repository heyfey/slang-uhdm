// § emptyNamedConnLowConnAtDecl137
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module top(input logic [1:0] x, output logic [1:0] y);
  sub u[1:0] (.a(x), .b(y), .c());
endmodule
