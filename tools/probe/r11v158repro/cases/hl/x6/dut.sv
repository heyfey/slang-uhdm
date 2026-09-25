// § arrQueryFoldAtBound158
package p;
  parameter [4:1] a = 0;
  parameter high = $high(a);
endpackage
module top(); import p::*; logic [high:0] w; endmodule
