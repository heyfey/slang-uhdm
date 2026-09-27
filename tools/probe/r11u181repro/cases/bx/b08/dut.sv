// § bitSelParenIdxSpan181 — a parenthesized index in an operation operand and a call argument
module top(input logic [31:0] din, input int i, output logic y, output int n);
  function automatic int f(logic a); return int'(a); endfunction
  assign y = din[(i+1)] ^ din[(i+2)];
  assign n = f(din[(i+3)]);
endmodule
