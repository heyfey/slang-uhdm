// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #1.0 b = a;
endmodule
