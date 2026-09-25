// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #0.5ns b = a;
endmodule
