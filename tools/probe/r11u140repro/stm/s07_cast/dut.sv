// § streamOperandBraceSpan140
module top(input logic [7:0] a, input logic [7:0] b, output logic [15:0] o, output logic [15:0] o2);
  typedef logic [15:0] w_t;
  assign o = w_t'({ << bit { a, b }});
endmodule
