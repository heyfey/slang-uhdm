// § wildcardConnRefSpan130
// case w04: .* on unpacked-array ports
module sub(input logic [1:0] d [2], output logic [1:0] q [2]);
  assign q = d;
endmodule
module top(input logic [1:0] d [2], output logic [1:0] q [2]);
  sub u(.*);
endmodule
