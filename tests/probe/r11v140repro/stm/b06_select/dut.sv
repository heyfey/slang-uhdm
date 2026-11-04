// § streamOperandBraceSpan140
module top(input logic [7:0] a, output logic [3:0] o);
  assign o = { >> { a[3:0] } };
endmodule
