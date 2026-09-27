// § bitSelParenIdxSpan181 — a parenthesized index in a procedural nonblocking read and an if condition
module top(input logic clk, input logic [31:0] din, input int i, output logic y);
  always_ff @(posedge clk) if (din[(i+1)]) y <= din[(i+2)];
endmodule
