// § paramFoldParenSpan131
// case q02: a parenthesized parameter default spanning two lines, reduced in the instance
module sub #(parameter int N = 3, parameter int P = (N +
                                                      1)) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub #(.N(5)) u(.o(o));
endmodule
