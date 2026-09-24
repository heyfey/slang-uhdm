// § wildcardConnRefSpan130
module sub(input logic a, output logic y);
  assign y = ~a;
endmodule
module top(input logic a, output logic [1:0] y);
  logic y0, y1;
  sub u0 (.*, .y(y0));
  sub u1 (.y(y1), .*);
  assign y = {y1, y0};
endmodule
