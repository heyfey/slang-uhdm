// § emptyNamedConnLowConnAtDecl137
// case en01: an explicitly empty named connection of an inout port
module sub(input logic a, inout wire b, output logic c);
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(), .c(y));
endmodule
