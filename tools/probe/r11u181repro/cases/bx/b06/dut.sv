// § bitSelParenIdxSpan181 — an unparenthesized index (control)
module top(input logic [31:0] din, input int i, output logic y, output logic z);
  assign y = din[i+1];
  assign z = din[i];
endmodule
