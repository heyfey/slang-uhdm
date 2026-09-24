// § wildcardConnRefSpan130
module sub(input logic a, output logic y);
  assign y = ~a;
endmodule
module top(input logic a, output logic y);
  if (1) begin : g
    sub u1(.*);
  end
endmodule
