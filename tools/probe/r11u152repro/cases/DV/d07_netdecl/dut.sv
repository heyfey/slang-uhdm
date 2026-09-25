// § delayLiteralValueText152
module top(input logic a, output logic b);
  wire #0.25 w = a;
  assign b = w;
endmodule
