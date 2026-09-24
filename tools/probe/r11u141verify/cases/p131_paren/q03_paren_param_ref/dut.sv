// § paramFoldParenSpan131
// case q03: a parenthesized reference to another parameter
module sub #(parameter int A = 2, parameter int P = (A)) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub #(.A(6)) u(.o(o));
endmodule
