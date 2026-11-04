// § streamOperandBraceSpan140
`define S(x) x
module top(input logic [7:0] a, output logic [7:0] o);
  assign o = `S({ << { a } });
endmodule
