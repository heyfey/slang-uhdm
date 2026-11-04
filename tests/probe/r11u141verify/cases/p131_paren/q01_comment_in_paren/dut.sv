// § paramFoldParenSpan131
// case q01: a parenthesized parameter default with a comment inside, overridden by a parenthesized value
module sub #(parameter int P = ( /*c*/ 8 )) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub #(.P((4))) u(.o(o));
endmodule
