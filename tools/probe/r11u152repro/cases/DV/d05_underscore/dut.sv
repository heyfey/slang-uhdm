// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #1_000 b = a;
endmodule
