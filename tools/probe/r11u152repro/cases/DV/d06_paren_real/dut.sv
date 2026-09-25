// § delayLiteralValueText152
module top(input logic a, output logic b);
  assign #(2.5) b = a;
endmodule
