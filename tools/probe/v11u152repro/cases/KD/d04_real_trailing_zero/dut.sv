// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #10.50 b = a;
endmodule
