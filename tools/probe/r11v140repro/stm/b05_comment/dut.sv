// § streamOperandBraceSpan140
module top(input logic [7:0] a, output logic [7:0] o);
  assign o = { << { /*c*/ a } };
endmodule
