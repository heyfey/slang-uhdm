// § pkgFoldLeftParenSpan158
package p;
  parameter int A = 72;
  parameter int B = 5;
  parameter int C = A / B;
endpackage
module top(); logic [p::C-1:0] x; endmodule
