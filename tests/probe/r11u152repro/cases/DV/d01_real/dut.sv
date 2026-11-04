// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #0.1 b = a;
endmodule
