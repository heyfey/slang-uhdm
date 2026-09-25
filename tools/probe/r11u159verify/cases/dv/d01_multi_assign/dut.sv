// § delayLiteralValueText152
module top(input logic a, output logic b, c);
  assign #0.1 b = a, c = ~a;
endmodule
