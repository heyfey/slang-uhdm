// § impPaLhsDisjointClone133
// case lc04: the package parameter comes from a macro; header import; the instance overrides the other parameter
`define PW_VAL (3 + 3)
package mp; parameter int PW = `PW_VAL; endpackage
module sub import mp::*; #(parameter int W = PW, parameter int K = 1) (output logic [W-1:0] o);
  assign o = K;
endmodule
module top(output logic [5:0] o); sub #(.K(2)) u(.o(o)); endmodule
