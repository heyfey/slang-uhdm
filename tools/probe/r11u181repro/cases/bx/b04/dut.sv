// § bitSelParenIdxSpan181 — a doubly parenthesized index and a parenthesized identifier index
module top(input logic [31:0] din, input int i, output logic y, output logic z);
  assign y = din[((i))];
  assign z = din[(i)];
endmodule
