// § emptyNamedConnLowConnAtDecl137
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module top(input logic x, output logic y);
  if (1) begin : g
    sub u(.a(x), .b(y), .c());
  end
endmodule
