// § streamOperandBraceSpan140
module top(input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
  assign o = { << { {a, b} } };
endmodule
