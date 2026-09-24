// § emptyNamedConnLowConnAtDecl137
// case en05: an explicitly empty named connection of an unpacked-array output port
module sub(input logic a, output logic [1:0] b [2], output logic c);
  assign b[0] = {a, a}; assign b[1] = 2'b00;
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(), .c(y));
endmodule
