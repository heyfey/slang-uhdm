// § delayLiteralValueText152
module child(input logic a, output logic b);
  assign #0.2 b = a;
endmodule
module top(input logic a, output logic b);
  child u(.a(a), .b(b));
endmodule
