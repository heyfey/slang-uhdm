// § streamOperandBraceSpan140
module top(input logic [15:0] a, output logic [15:0] o);
  assign o = { << byte {  a  } };
endmodule
