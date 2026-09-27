// § bitSelParenIdxSpan181 — a macro-born parenthesized index in a continuous assignment
`define IX(i) ((i)+1)
module top(input logic [31:0] din, input int i, output logic y);
  assign y = din[`IX(i)];
endmodule
