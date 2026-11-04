// § emptyNamedConnLowConnAtDecl137
module sub(input logic a, input logic d, output logic b);
  assign b = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .d(), .b(y));
endmodule
