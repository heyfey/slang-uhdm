// § bitSelParenIdxSpan181 — a parenthesized index in a concatenation operand and a ternary
module top(input logic [31:0] din, input int i, input logic s, output logic [1:0] y, output logic z);
  assign y = {din[(i+1)], din[(i)]};
  assign z = s ? din[(i+2)] : din[(i*2)];
endmodule
