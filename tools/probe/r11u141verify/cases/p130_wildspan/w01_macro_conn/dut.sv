// § wildcardConnRefSpan130
// case w01: the .* connection comes from a macro
`define CONN .*
module sub(input logic a, input logic [3:0] b, output logic y);
  assign y = a & b[0];
endmodule
module top(input logic a, input logic [3:0] b, output logic y);
  sub u(`CONN);
endmodule
