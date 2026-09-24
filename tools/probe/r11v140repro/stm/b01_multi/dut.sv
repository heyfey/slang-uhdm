// § streamOperandBraceSpan140
module top(input logic [7:0] a, input logic [7:0] b, output logic [15:0] o);
  assign o = { << 8 { a, b } };
endmodule
