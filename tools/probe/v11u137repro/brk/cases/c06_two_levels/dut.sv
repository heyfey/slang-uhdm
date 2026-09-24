// § emptyNamedConnLowConnAtDecl137
module leaf(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module mid(input logic a, output logic b);
  leaf l(.a(a), .b(b), .c());
endmodule
module top(input logic x, output logic y);
  mid m(.a(x), .b(y));
endmodule
