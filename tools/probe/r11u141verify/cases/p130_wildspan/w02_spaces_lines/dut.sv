// § wildcardConnRefSpan130
// case w02: .* on its own line with spaces around it
module sub(input logic a, output logic y);
  assign y = ~a;
endmodule
module top(input logic a, output logic y);
  sub u (
      .*
  );
endmodule
