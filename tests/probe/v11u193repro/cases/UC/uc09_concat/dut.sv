// § caUnsizedRhsClonePerInst193
module m (input logic c, output logic a, output logic b);
  assign {a, b} = c ? 2'b10 : '1;
endmodule
module top (input logic c, output logic a, output logic b);
  m u_a (.c(c), .a(a), .b(b));
endmodule
