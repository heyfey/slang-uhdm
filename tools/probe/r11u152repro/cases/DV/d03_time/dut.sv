// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #10ns b = a;
endmodule
