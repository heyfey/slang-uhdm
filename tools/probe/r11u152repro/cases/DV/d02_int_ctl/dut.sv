// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #5 b = a;
endmodule
