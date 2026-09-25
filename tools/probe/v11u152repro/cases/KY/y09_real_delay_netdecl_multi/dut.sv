// § delayLiteralValueText152
module top(input logic a, output logic b, output logic c);
  wire #1.5 w1 = a, w2 = a;
  assign b = w1;
  assign c = w2;
endmodule
