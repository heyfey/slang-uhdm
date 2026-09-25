// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #1.5e3 b = a;
endmodule
