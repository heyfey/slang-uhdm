// § paramFoldParenSpan131
// case q06: a parenthesized ternary default, the instance overriding the selector
module sub #(parameter bit S = 0, parameter int P = (S ? 7 : 3)) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub #(.S(1)) u(.o(o));
endmodule
