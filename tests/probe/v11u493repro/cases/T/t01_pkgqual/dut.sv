// § enumCastChainKeepsInnerCast493
package p;
  typedef int t32;
endpackage
module top(input int a, output int v);
  assign v = int'(p::t32'(a));
endmodule
