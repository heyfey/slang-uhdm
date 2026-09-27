// § bitSelParenIdxSpan181 (v11u181 break: parenthesized index through macros: parens outside, parens inside, parens from two macros)
`define I (i)
`define J i
`define K(x) (x+1)
module top(input logic [7:0] a, input logic [2:0] i, output logic [3:0] y);
  assign y[0] = a[`I];
  assign y[1] = a[(`J)];
  assign y[2] = a[`K(i)];
  assign y[3] = a[(`K(`J))];
endmodule
