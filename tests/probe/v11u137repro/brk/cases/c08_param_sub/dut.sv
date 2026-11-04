// § emptyNamedConnLowConnAtDecl137
module sub #(parameter W = 2)(input logic [W-1:0] a, output logic [W-1:0] b, output logic [W-1:0] c);
  assign b = a; assign c = a;
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  sub #(.W(4)) u(.a(x), .b(y), .c());
endmodule
