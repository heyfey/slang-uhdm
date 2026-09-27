// § bitSelParenIdxSpan181 — a two-dimensional select with parenthesized indices (control: no r11u181 law fires)
module top(input logic [7:0] mem [4][4], input int i, input int j, output logic [7:0] y);
  assign y = mem[(i)][(j+1)];
endmodule
