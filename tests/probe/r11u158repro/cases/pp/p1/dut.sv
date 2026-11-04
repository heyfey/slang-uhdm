// § pkgFoldLeftParenSpan158
package p;
  parameter int A = 72;
  parameter int B = 5;
  parameter int C = (A + B - 1)/B;
endpackage
module top(); import p::*; logic [C-1:0] x; endmodule
