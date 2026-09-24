// § wildcardConnRefSpan130
module sub(input logic a, output logic y);
  assign y = a;
endmodule
module top(input logic a, output logic y);
  sub u1(.*);
endmodule
module top2(input logic a, output logic y);
  sub u2(.*);
endmodule
