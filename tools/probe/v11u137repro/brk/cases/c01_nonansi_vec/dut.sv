// § emptyNamedConnLowConnAtDecl137
module sub(a, b, c);
  input [3:0] a;
  output [3:0] b;
  output [3:0] c;
  wire [3:0] c;
  assign b = a; assign c = a;
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  sub u(.a(x), .b(y), .c(  ));
endmodule
