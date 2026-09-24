// § emptyNamedConnLowConnAtDecl137
// case en03: the empty port's declaration carries an attribute and spans two lines
module sub(input logic a,
           (* keep *) output logic
             [3:0] b,
           output logic c);
  assign b = {4{a}};
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(), .c(y));
endmodule
