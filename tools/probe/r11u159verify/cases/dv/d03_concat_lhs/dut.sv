// § delayLiteralValueText152
module top(input logic [1:0] a, output logic b, c);
  assign #2.5 {b, c} = a;
endmodule
