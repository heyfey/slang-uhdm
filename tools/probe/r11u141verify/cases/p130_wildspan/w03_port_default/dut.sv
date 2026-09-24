// § wildcardConnRefSpan130
// case w03: .* where the child has an input port with a default value the parent lacks
module sub(input logic a, input logic en = 1'b1, output logic y);
  assign y = a & en;
endmodule
module top(input logic a, output logic y);
  sub u(.*);
endmodule
