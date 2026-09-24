// § wildcardConnRefSpan130
module sub(input logic a, input logic b, output logic y);
  assign y = a & b;
endmodule
module top(input logic a, input logic b, output logic y);
  sub u1
  (
    .*
  );
endmodule
