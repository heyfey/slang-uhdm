// § paramFoldParenSpan131
// case q05: a parenthesized package localparam default read through an override actual
package p;
  localparam int L = (3 + 2);
endpackage
module sub #(parameter int P = 1) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub #(.P((p::L))) u(.o(o));
endmodule
