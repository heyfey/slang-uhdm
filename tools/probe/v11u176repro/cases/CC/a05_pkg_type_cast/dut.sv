// § castRhsClonePerInst176
package p;
  typedef logic [5:0] b_t;
endpackage
module sub (input logic [7:0] w);
  assign a = p::b_t'(w);
endmodule
module top (input logic [7:0] x);
  sub u1 (.w(x));
  sub u2 (.w(x));
endmodule
