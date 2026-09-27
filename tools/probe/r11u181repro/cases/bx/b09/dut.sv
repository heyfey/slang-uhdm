// § bitSelParenIdxSpan181 — a parenthesized index on a memory word and a part-select base
module top(input logic [7:0] mem [16], input logic [31:0] din, input int i, output logic [7:0] y, output logic [3:0] z);
  assign y = mem[(i+1)];
  assign z = din[(i+1) +: 4];
endmodule
