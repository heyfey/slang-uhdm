// § emptyNamedConnLowConnAtDecl137
module sub(input logic [3:0] a, output logic [3:0] b, output logic [3:0] c);
  assign b = a; assign c = a;
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  sub u(.a(x), .b(y), .c( ));
endmodule
